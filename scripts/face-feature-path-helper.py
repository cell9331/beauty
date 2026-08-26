#!/usr/bin/env python3
"""Descriptor-relative filesystem mutations for the Phase 89 batch runner."""

import errno
import json
import os
import re
import secrets
import stat
import sys
import tempfile


MAX_STDIN_BYTES = 16 * 1024 * 1024
SAFE_NAME = re.compile(r"^[A-Za-z0-9_.-]{1,120}$")


class PathSafetyError(Exception):
    pass


def normalized_absolute(raw):
    if not raw or any(character in raw for character in ("\n", "\r", "\0")):
        raise PathSafetyError()
    if ".." in raw.replace("\\", "/").split("/"):
        raise PathSafetyError()
    path = os.path.normpath(os.path.abspath(raw))
    if path == os.path.sep:
        raise PathSafetyError()
    return path


def checked_name(name):
    if not SAFE_NAME.fullmatch(name) or name in (".", ".."):
        raise PathSafetyError()
    return name


def open_directory(path, create=False):
    path = normalized_absolute(path)
    descriptor = os.open(
        os.path.sep,
        os.O_RDONLY | os.O_DIRECTORY | os.O_CLOEXEC,
    )
    try:
        for component in path.split(os.path.sep)[1:]:
            checked_name(component)
            try:
                next_descriptor = os.open(
                    component,
                    os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                    dir_fd=descriptor,
                )
            except FileNotFoundError:
                if not create:
                    raise
                os.mkdir(component, mode=0o700, dir_fd=descriptor)
                next_descriptor = os.open(
                    component,
                    os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                    dir_fd=descriptor,
                )
            os.close(descriptor)
            descriptor = next_descriptor
        return descriptor
    except Exception:
        os.close(descriptor)
        raise


def split_direct_child(path):
    path = normalized_absolute(path)
    parent = os.path.dirname(path)
    name = checked_name(os.path.basename(path))
    if not parent or parent == path:
        raise PathSafetyError()
    return path, parent, name


def ensure_directory(path):
    descriptor = open_directory(path, create=True)
    os.close(descriptor)
    return normalized_absolute(path)


def make_temporary(parent, prefix, suffix, directory):
    parent = normalized_absolute(parent)
    checked_name(prefix)
    if suffix:
        checked_name("x" + suffix)
    parent_descriptor = open_directory(parent)
    try:
        for _ in range(128):
            name = checked_name(prefix + secrets.token_hex(8) + suffix)
            try:
                if directory:
                    os.mkdir(name, mode=0o700, dir_fd=parent_descriptor)
                else:
                    descriptor = os.open(
                        name,
                        os.O_WRONLY | os.O_CREAT | os.O_EXCL |
                        os.O_NOFOLLOW | os.O_CLOEXEC,
                        0o600,
                        dir_fd=parent_descriptor,
                    )
                    os.close(descriptor)
                os.fsync(parent_descriptor)
                return os.path.join(parent, name)
            except FileExistsError:
                continue
        raise PathSafetyError()
    finally:
        os.close(parent_descriptor)


def read_stdin():
    data = sys.stdin.buffer.read(MAX_STDIN_BYTES + 1)
    if len(data) > MAX_STDIN_BYTES:
        raise PathSafetyError()
    return data


def atomic_write(path, data, after_parent_open=None):
    path, parent, destination = split_direct_child(path)
    parent_descriptor = open_directory(parent)
    temporary_name = None
    try:
        if after_parent_open is not None:
            after_parent_open()
        try:
            metadata = os.stat(
                destination, dir_fd=parent_descriptor, follow_symlinks=False
            )
            if not stat.S_ISREG(metadata.st_mode):
                raise PathSafetyError()
        except FileNotFoundError:
            pass
        temporary_name = checked_name(
            "." + destination + ".tmp." + secrets.token_hex(8)
        )
        descriptor = os.open(
            temporary_name,
            os.O_WRONLY | os.O_CREAT | os.O_EXCL |
            os.O_NOFOLLOW | os.O_CLOEXEC,
            0o600,
            dir_fd=parent_descriptor,
        )
        try:
            view = memoryview(data)
            written = 0
            while written < len(view):
                count = os.write(descriptor, view[written:])
                if count <= 0:
                    raise PathSafetyError()
                written += count
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
        os.replace(
            temporary_name,
            destination,
            src_dir_fd=parent_descriptor,
            dst_dir_fd=parent_descriptor,
        )
        temporary_name = None
        os.fsync(parent_descriptor)
    finally:
        if temporary_name is not None:
            try:
                os.unlink(temporary_name, dir_fd=parent_descriptor)
            except FileNotFoundError:
                pass
        os.close(parent_descriptor)
    return path


def remove_file(path, after_parent_open=None):
    _, parent, name = split_direct_child(path)
    parent_descriptor = open_directory(parent)
    try:
        if after_parent_open is not None:
            after_parent_open()
        try:
            metadata = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
        except FileNotFoundError:
            return
        if not (stat.S_ISREG(metadata.st_mode) or stat.S_ISLNK(metadata.st_mode)):
            raise PathSafetyError()
        os.unlink(name, dir_fd=parent_descriptor)
        os.fsync(parent_descriptor)
        try:
            os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
        except FileNotFoundError:
            return
        raise PathSafetyError()
    finally:
        os.close(parent_descriptor)


def remove_directory_contents(descriptor):
    for name in os.listdir(descriptor):
        checked_name(name)
        metadata = os.stat(name, dir_fd=descriptor, follow_symlinks=False)
        if stat.S_ISDIR(metadata.st_mode):
            child = os.open(
                name,
                os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                dir_fd=descriptor,
            )
            try:
                remove_directory_contents(child)
            finally:
                os.close(child)
            os.rmdir(name, dir_fd=descriptor)
        elif stat.S_ISREG(metadata.st_mode) or stat.S_ISLNK(metadata.st_mode):
            os.unlink(name, dir_fd=descriptor)
        else:
            raise PathSafetyError()


def remove_tree(path, expected_parent, prefix, after_parent_open=None):
    path, parent, name = split_direct_child(path)
    expected_parent = normalized_absolute(expected_parent)
    checked_name(prefix)
    if parent != expected_parent or not name.startswith(prefix):
        raise PathSafetyError()
    parent_descriptor = open_directory(parent)
    try:
        if after_parent_open is not None:
            after_parent_open()
        try:
            metadata = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
        except FileNotFoundError:
            return
        if stat.S_ISLNK(metadata.st_mode):
            os.unlink(name, dir_fd=parent_descriptor)
        elif stat.S_ISDIR(metadata.st_mode):
            child = os.open(
                name,
                os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                dir_fd=parent_descriptor,
            )
            try:
                remove_directory_contents(child)
            finally:
                os.close(child)
            os.rmdir(name, dir_fd=parent_descriptor)
        else:
            raise PathSafetyError()
        os.fsync(parent_descriptor)
    finally:
        os.close(parent_descriptor)


def self_test():
    temporary_base = os.path.realpath(tempfile.gettempdir())
    root = tempfile.mkdtemp(prefix="beauty_path_helper_", dir=temporary_base)
    root = os.path.realpath(root)
    try:
        trusted = os.path.join(root, "trusted")
        moved = os.path.join(root, "moved")
        outside = os.path.join(root, "outside")
        ensure_directory(trusted)
        ensure_directory(outside)
        atomic_write(os.path.join(trusted, "victim"), b"owned")
        atomic_write(os.path.join(outside, "victim"), b"outside")

        def swap_cleanup_parent():
            os.rename(trusted, moved)
            os.symlink(outside, trusted)

        remove_file(
            os.path.join(trusted, "victim"),
            after_parent_open=swap_cleanup_parent,
        )
        if os.path.exists(os.path.join(moved, "victim")):
            raise PathSafetyError()
        with open(os.path.join(outside, "victim"), "rb") as handle:
            if handle.read() != b"outside":
                raise PathSafetyError()
        os.unlink(trusted)
        os.rename(moved, trusted)

        publish_parent = os.path.join(root, "publish")
        moved_publish = os.path.join(root, "moved-publish")
        outside_publish = os.path.join(root, "outside-publish")
        ensure_directory(publish_parent)
        ensure_directory(outside_publish)
        atomic_write(os.path.join(outside_publish, "report"), b"outside-report")

        def swap_publish_parent():
            os.rename(publish_parent, moved_publish)
            os.symlink(outside_publish, publish_parent)

        atomic_write(
            os.path.join(publish_parent, "report"),
            b"owned-report",
            after_parent_open=swap_publish_parent,
        )
        with open(os.path.join(moved_publish, "report"), "rb") as handle:
            if handle.read() != b"owned-report":
                raise PathSafetyError()
        with open(os.path.join(outside_publish, "report"), "rb") as handle:
            if handle.read() != b"outside-report":
                raise PathSafetyError()
        os.unlink(publish_parent)
        os.rename(moved_publish, publish_parent)

        failure_root = os.path.join(root, "cleanup-failure")
        ensure_directory(failure_root)
        fifo_path = os.path.join(failure_root, "unexpected")
        os.mkfifo(fifo_path, 0o600)
        try:
            remove_tree(failure_root, root, "cleanup-")
        except PathSafetyError:
            pass
        else:
            raise PathSafetyError()
        if not os.path.exists(fifo_path):
            raise PathSafetyError()
        descriptor = open_directory(failure_root)
        try:
            os.unlink("unexpected", dir_fd=descriptor)
        finally:
            os.close(descriptor)

        print(
            "path_helper_self_test=PASS parent_swap_timing=1 "
            "outside_preserved=1 cleanup_failure=1"
        )
    finally:
        remove_tree(root, temporary_base, "beauty_path_helper_")


def main(arguments):
    if arguments == ["--self-test"]:
        self_test()
        return
    if not arguments:
        raise PathSafetyError()
    command = arguments[0]
    if command == "ensure-directory" and len(arguments) == 2:
        print(ensure_directory(arguments[1]))
    elif command == "temp-file" and len(arguments) == 4:
        print(make_temporary(arguments[1], arguments[2], arguments[3], False))
    elif command == "temp-directory" and len(arguments) == 3:
        print(make_temporary(arguments[1], arguments[2], "", True))
    elif command == "atomic-write-stdin" and len(arguments) == 2:
        atomic_write(arguments[1], read_stdin())
    elif command == "remove-file" and len(arguments) == 2:
        remove_file(arguments[1])
    elif command == "remove-tree" and len(arguments) == 4:
        remove_tree(arguments[1], arguments[2], arguments[3])
    else:
        raise PathSafetyError()


if __name__ == "__main__":
    try:
        main(sys.argv[1:])
    except (OSError, PathSafetyError, ValueError):
        print("path_operation_failed", file=sys.stderr)
        raise SystemExit(1)
