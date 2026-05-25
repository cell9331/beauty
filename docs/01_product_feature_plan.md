# 01. Beauty SDK Product Feature Plan

## 1. Product positioning

This SDK is oriented to picture editing, camera shooting, short videos, live broadcasts, social chats, ID photos, AI portraits and other scenarios, and provides beauty and portrait refinement capabilities such as beautiful photo show, light face camera, and wake-up photo.

Core goals:

- Supports real-time preview and offline image processing.
- Supports natural, controllable, fine-grained face adjustment.
- Supports multiple presets, one-click beautification, and also supports manual fine-tuning by advanced users.
- Supports multiple input scenarios such as photography, video, live streaming, portrait picture editing, etc.
- Provided as SDK for App integration, function modules can be tailored as needed.

---

## 2. Function Overview

Beauty SDK can be divided into the following major modules:

1. Basic beauty
2. Face reshaping
3. Eye adjustment
4. Nose adjustment
5. Mouth adjustment
6. Eyebrow adjustment
7. Chin/forehead/hairline adjustment
8. Teeth/Lip Color/Eye Enhancement
9. Makeup system
10. Filter system
11. Body beauty
12. Background and portrait segmentation
13. Stylized effects
14. One-click preset template
15. Multi-face processing
16. SDK access and parameter control

---

# 3. Basic beauty function

Basic beauty care mainly solves problems such as skin texture, skin color, blemishes, and clarity.

## 3.1 Microdermabrasion

Function description: Make skin smoother, reduce pores, fine lines, and minor spots.

Parameter suggestions:

- Microdermabrasion intensity: 0 ~ 100
- Preserve skin texture: 0 ~ 100
- Face area protection: On/Off
- Facial sharpness protection: On/Off

Product Note:

- Don't make your face look plastic.
- The bridge of the nose, eyes, lips, and eyebrow edges need to be kept clear.
- Mid-to-high-end solutions need to support "skin area recognition" and only process skin areas.

## 3.2 Whitening

Function description: Improves the brightness of skin tone and makes skin tone cleaner.

Parameter suggestions:

- Whitening intensity: 0 ~ 100
- Skin tone: cool white/natural/warm white
- Highlight protection: on/off

## 3.3 Ruddy

Function description: Increase facial complexion.

Parameter suggestions:

- Ruddy intensity: 0 ~ 100
-Ruddy areas: cheeks / whole face / natural distribution

## 3.4 Acne removal/freckle removal/blemish repair

Function description: Remove acne, spots, moles, and small blemishes on the skin.

Functional form:

- Automatically remove acne
- Manually select acne removal
- Automatically remove freckles
- Partial repair pen

Parameter suggestions:

- Defect recognition strength: 0 ~ 100
- Repair naturalness: 0 ~ 100
- Whether to keep moles: On/Off

## 3.5 Dark circles/nasolabial folds/tear trough treatment

Function description: Reduce fatigue.

Adjustable items:

- Lighten dark circles
- Lighten tear troughs
- Reduce nasolabial folds
- Reduce forehead lines
- Reduce fine lines around the eyes

Parameter suggestions:

- Strength: 0 ~ 100
- Naturalness: 0 ~ 100

## 3.6 Clarity / Sharpening

Function description: Enhance facial features, hair, and contour definition.

Parameter suggestions:

- Clarity: 0 ~ 100
- Facial features enhancement: 0 ~ 100
- Hair enhancement: 0 ~ 100
- Skin sharpening protection: On/Off

---

# 4. Face reshaping function

Face reshaping is one of the core modules of the beauty SDK.

## 4.1 Face slimming

Function description: Narrow the width of the face.

Adjustable items:

- Overall face slimming
- Face slimming on the left side of the face
- Face slimming on the right side of the face
- Jawline tightening
- Cheek reduction
- Narrowing of cheekbones

Parameter suggestions:

- Face slimming intensity: 0 ~ 100
- Symmetry: On/Off
- Face protection boundary: 0 ~ 100

## 4.2 Small face

Function description: Reduce the overall facial area while maintaining the natural proportions of the facial features.

Parameter suggestions:

- Small face intensity: 0 ~ 100
- Facial features follow zoom: On/Off

## 4.3 Narrow face

Function description: Mainly compresses the width of the cheeks and mid-face.

Suitable scenarios:

- round face
- wide face
- Lens close-range distortion correction

## 4.4 V face

Functional description: Make the chin more pointed and the face closer to a V-shape.

Parameter suggestions:

- V face intensity: 0 ~ 100
- Chin sharpness: 0 ~ 100
- Jaw contraction: 0 ~ 100

## 4.5 Mandibular line optimization

Function description: Make facial contours clearer.

Adjustable items:

- Jawline definition
- Jaw width
- Narrowing of the mandibular angle
- Natural transition between chin and jaw

## 4.6 Zygomatic bone adjustment

Function description: Adjust the mid-face contour.

Adjustable items:

- Zygoma adduction
- Softening of cheekbones
- Fine adjustment of cheekbone height

## 4.7 Facial length adjustment

Function description: Adjust the vertical proportion of the face.

Adjustable items:

- Shorten face length
- Elongate the face shape
- Atrium shortened / lengthened
- The lower court is shortened/lengthened

## 4.8 Facial symmetry correction

Function description: Improve left and right face asymmetry.

Adjustable items:

- Automatic symmetry
- Correction of left and right face width
- Left and right eye height correction
- Height correction of the left and right corners of the mouth
- Correction of left and right face contours

---

# 5. Eye adjustment function

The eyes are the most sensitive and commonly used area for fine-tuning by users and require segmentation capabilities.

## 5.1 Big eyes/small eyes

Function description: Adjust the overall size of the eyes.

Adjustable items:

- Overall enlargement of both eyes
- Left eye individually enlarged
- Right eye individually enlarged
- Eye height adjustment
- Eye width adjustment

Parameter suggestions:

- Big Eye Strength: -100 ~ 100
  - Negative numbers: narrow the eyes
  - Positive numbers: enlarge eyes
- Left and right sync: on/off
- Eye protection: On / Off

## 5.2 Eye distance adjustment

Function description: Adjust the distance between the two eyes.

Adjustable items:

- Eye distance is shortened
- Distance between eyes
- Lateral movement of left eye
- Right eye moves laterally

Parameter suggestions:

- Eye distance: -100 ~ 100
  - Negative number: Eye distance becomes closer
  -Positive number: the distance between the eyes becomes farther

## 5.3 Adjust the upper and lower position of the eyes

Function description: Adjust the vertical position of the eyes on the face.

Adjustable items:

- Move eyes up/down
- Move left eye up/down
- Move the right eye up/down

Parameter suggestions:

- Eye Y-axis position: -100 ~ 100

## 5.4 Eye rotation/tilt adjustment

Function description: Adjust the angle of the eyes to make them softer or more vivid.

Adjustable items:

- Left eye rotation
- Right eye rotation
- The tail of the eyes is raised
- Press down the end of the eye
- Eye head height adjustment
- Eye tail height adjustment

Suitable for:

- Smart eyes
- droopy eyes
- cat eye
- Gentle eyes

## 5.5 Eye shape adjustment

Adjustable items:

- round eyes
- Almond eyes
- peach blossom eyes
- Danfeng eyes
- droopy eyes
- cat eye
- European eye shape

Implementation method:

- Can be used as advanced presets, not necessarily all open as independent parameters.

## 5.6 Eye corner adjustment

Adjustable items:

- Open the inner corner of the eye
- Open the outer corners of the eyes
- Eye head stretching
- Eye end stretching
- Sharpness of eye corners

Parameter suggestions:

- Inner corner of eye: 0 ~ 100
- Outer corner of eye: 0 ~ 100
- Raising the tail of the eyes: -100 ~ 100

## 5.7 Lying Silkworm

Functional description: Enhance the eyes under the eyes and make them more friendly.

Adjustable items:

- Lying silkworm enhancement
- Silkworm Shadow
- Silkworm highlighter
- lying width

## 5.8 Eye light

Function description: Add eye highlights to make eyes brighter.

Adjustable items:

- Eye light intensity
- Eye light style
- Eye light position
- Left and right eye synchronization

## 5.9 Eye Bag/Dark Circle Repair

Adjustable items:

- Remove eye bags
- Lighten dark circles
- Lighten tear troughs
- Brighten the eye area

## 5.10 Eyeball enhancement

Adjustable items:

- Brighten the whites of the eyes
- Remove yellowish whites of eyes
- Eyeball clarity
- dilation of pupils
- Fine-tuning eye color

---

# 6. Nose adjustment function

Nose adjustment should take into account three-dimensionality and naturalness, and should not be excessively deformed.

## 6.1 Slim nose

Function description: Narrow the width of the nose wing and bridge of the nose.

Adjustable items:

- Narrowing of the bridge of the nose
- Nose retraction
- Reduction of nose tip
- Narrowing of nostrils

Parameter suggestions:

- Slim nose strength: 0 ~ 100
- Nose width: -100 ~ 100
- Nose size: -100 ~ 100

## 6.2 Nose Bridge Adjustment

Adjustable items:

- Increased nose bridge
- Narrowing of the bridge of the nose
- Nose bridge highlight enhancement
- Bridge shadow enhancement
- Straight line correction of nose bridge

## 6.3 Nose tip adjustment

Adjustable items:

- Reduction of nose tip
- Upturned nose
- Press down the tip of the nose
- Nose roundness
- Sharpness of nose

## 6.4 Nose adjustment

Adjustable items:

- Narrowing of the nose
- Nose symmetry correction
- Nose height adjustment
- Nose shadow enhancement

## 6.5 Nose position adjustment

Adjustable items:

- Move the nose up/down as a whole
- Move the nose overall to the left/right
- Overall nose scaling

## 6.6 Nasal base / philtrum relationship

Adjustable items:

- Filling feeling at the nasal base
-Shortened philtrum
-Nasolabial distance adjustment

---

# 7. Mouth adjustment function

Mouth adjustment includes not only shape adjustment, but also expression, lip color, and teeth treatment.

## 7.1 Mouth size

Adjustable items:

- Enlarge/reduce the entire mouth
- Mouth width
- Mouth height
- Upper lip thickness
- Lower lip thickness

Parameter suggestions:

- Mouth size: -100 ~ 100
- Mouth width: -100 ~ 100
- Lip thickness: -100 ~ 100

## 7.2 Mouth position

Adjustable items:

- Move mouth up/down
- Move mouth left/right
- Mouth rotation correction

## 7.3 Mouth corner adjustment

Function description: Make expressions more natural and smiley.

Adjustable items:

- Corners of mouth raised
- Press down the corners of your mouth
- Adjust the left corner of the mouth individually
- Adjust the right corner of the mouth individually
- Smile intensity

Parameter suggestions:

- Smile: 0 ~ 100
- Mouth corner angle: -100 ~ 100

## 7.4 Lip shape adjustment

Adjustable items:

- M lip
- smile lips
-Thick lips
- Thin lips
-Pouty lips
- Lip peak enhancement
- Lip enhancement

## 7.5 Renzhong adjustment

Adjustable items:

-Shortened philtrum
- Elongated philtrum
- philtrum clarity
- Shadow among people

## 7.6 Teeth Whitening

Adjustable items:

- Teeth whitening
- Remove yellow teeth
- Teeth brightness
-Tooth edge protection

## 7.7 Lip color enhancement

Adjustable items:

- Natural lip color
- lipstick strength
- Lip saturation
- Lip gloss
- Reduce lip lines

---

# 8. Eyebrow adjustment function

Eyebrows will obviously affect the overall temperament and are suitable to be combined with the makeup system.

## 8.1 Eyebrow position

Adjustable items:

- Move eyebrows up/down
- Move left eyebrow up/down
- Move the right eyebrow up/down
- Eyebrow distance adjustment

## 8.2 Eyebrow shape

Adjustable items:

- Flat eyebrow
- Curved eyebrows
- Liu Yemei
- wild eyebrow
- raised eyebrows
- Standard eyebrows

## 8.3 Eyebrow thickness

Adjustable items:

- thickening eyebrows
- Eyebrows become thinner
- The tail of the eyebrow is lengthened
-Brow softening

## 8.4 Eyebrow color

Adjustable items:

- black
- brown
- light brown
- gray brown
- Custom colors
- Eyebrow color intensity

---

# 9. Forehead/chin/hairline function

## 9.1 Forehead adjustment

Adjustable items:

- The forehead becomes higher
- The forehead becomes lower
- Full forehead
- A feeling of filling in the temples

## 9.2 Chin adjustment

Adjustable items:

- Chin becomes pointed
- Shortening of the chin
- Chin becomes longer
- Move chin left/right
- Feeling of protruding chin
- Chin roundness

## 9.3 Hairline adjustment

Adjustable items:

- Lowered hairline
- Improved hairline
- Forehead replacement
- Bangs area protection

---

# 10. Makeup System

The makeup system can be divided into "overall makeup templates" and "partial makeup components".

## 10.1 Overall makeup template

Available:

- Daily makeup
- Commuting makeup
- Clear makeup
- Sweet girl makeup
- Pure lust makeup
- Korean makeup
- Hong Kong style makeup
- Retro makeup
- ID photo makeup
- Natural makeup for boys

Parameter suggestions:

- Overall strength of makeup: 0 ~ 100
- Makeup transparency: 0 ~ 100
- Whether to follow the face angle: On/Off

## 10.2 Partial makeup

### Base makeup

- Foundation
- Concealer
- brighten
- Contouring
- Highlights

### Eye makeup

- eye shadow
- Eyeliner
- eyelashes
- Wocan
- Color contact lenses
- Eye light

### Eyebrow makeup

- Eyebrow shape
- Eyebrow color
- Eyebrow density

### Lip makeup

- lipstick
- lip gloss
- matte lips
- Hydrating lips
- Gradient lip

### Blush

- Apple cheek blush
- Blush under eyes
- Tip of nose blush
- Contouring blush

### Contouring / Highlighting

- Nose shadow
- Highlight on the bridge of nose
- Cheekbone shading
- Jaw shadow
- Forehead highlight

---

# 11. Filter system

Filters are used to control the overall style of photos and videos.

## 11.1 Basic filter classification

- natural
- Clear
- fair complexion
- cream
- film
- Retro
- Hong Kong style
- Japanese
- Korean style
- Nuanyang
- cold white
- dark tone
- Cinematic feel
- black and white

## 11.2 Filter parameters

- Filter strength: 0 ~ 100
- brightness
- Contrast
- saturation
- color temperature
- Hue
- Highlights
- shadow
- fade
- Particles
- Vignetting
- sharpen

## 11.3 LUT support

The SDK can support importing LUT files for expanding filter packages.

Recommended support:

- 3D LUT
- Cube LUT
- Built-in LUT pack
- Custom LUT loading
- Hot update of filter pack

---

# 12. Body beautification function

If the SDK covers full-body shooting or video scenes in the future, body beauty can be added.

## 12.1 Long legs

Adjustable items:

- Leg elongation
- Lengthened calves
- Thigh elongation
- Height proportion adjustment

## 12.2 Lose weight

Adjustable items:

- Narrow the waist
- Shoulder width adjustment
- arms become thinner
- thinning of legs
- Crotch adjustment

## 12.3 Optimization of head-to-body ratio

Adjustable items:

- Reduced head size
- Optimized shoulder-neck ratio
- Upper body proportion adjustment

---

# 13. Background and portrait segmentation

## 13.1 Portrait segmentation

Function description: Identify portrait areas and separate people and background.

Available capabilities:

- Background blur
- Background replacement
- Background transparency
- Background coloring
- Portrait strokes
- Depth of field effect

## 13.2 Background blur

Adjustable items:

- Blur intensity
- Spot pattern
- Depth of field range
- Edge feathering

## 13.3 Background replacement

Available scenarios:

- ID photo
- Live broadcast background
- AI photo
- Product pictures/avatars

---

# 14. Stylized effect

## 14.1 Portrait style

- Comic style
- watercolor style
- National style
- Oil painting style
- Cyber style
- Vintage film
- 3D cartoon
- AI photo

## 14.2 Special Effect Stickers

- cat ears
- Rabbit ears
- glasses
- Headgear
- Dynamic stickers
- Holiday stickers
- AR mask

## 14.3 Light effect

- Backlight
- Soft light
- Starlight
- light spot
-Ambient light
- rim light

---

# 15. One-click preset template

The beauty SDK should not only give users a bunch of parameters, but also provide one-click presets.

## 15.1 Basic presets

- Native nature
- Clear and fair skin
- Sweet and cute
- Sophisticated and photogenic
- Light and mature temperament
- Boys are natural
-Natural ID photo

## 15.2 Scene Preset

- Selfie
- Group photo
- Live broadcast
- video call
- ID photo
- Night scene selfie
- Warm light indoors
- Outdoor sunshine

## 15.3 Crowd preset

- Girls are natural
- Girls are exquisite
- Boys are natural
- Refreshing for boys
- Child protection mode
- Natural grooming for middle-aged and elderly people

Child Protection Mode Recommendations:

- Significant changes in face shape are prohibited.
- No heavy makeup.
- Only slight skin tone, brightness, clarity optimization allowed.

---

# 16. Multiple face processing

## 16.1 Multi-face recognition

Function description: Recognize multiple faces in the same picture or video.

Ability requirements:

- Supports up to N faces.
-Support main face recognition.
-Supports selecting a certain face to adjust individually.
- Support unified beauty for everyone.
- Support different people using different parameters.

## 16.2 Main face strategy

Optional strategies:

- The face with the largest area is used as the main face.
- The face closest to the center of the screen is used as the main face.
- User manually selects the main face.
- Keep track of faces recognized for the first time.

---

# 17. SDK parameter design suggestions

## 17.1 Parameter naming example

Basic beauty:

- skinSmoothing
- skinWhitening
- skinRosy
- acneRemoval
- darkCircleRemoval
- wrinkleRemoval
- faceSharpen

Face shape:

- faceSlim
- faceSmall
- jawSlim
- cheekboneSlim
- chinLength
- chinWidth
- foreheadHeight

Eyes:

- eyeSize
- eyeWidth
- eyeHeight
- eyeDistance
- eyeYPosition
- eyeRotation
- innerEyeCorner
- outerEyeCorner
- eyeTailLift
- eyeBrighten
- eyeWhite

Nose:

- noseSlim
- noseBridgeHeight
- noseWingSlim
- noseTipSize
- noseTipLift
- nosePositionY

Mouth:

- mouthSize
- mouthWidth
- mouthHeight
- mouthYPosition
- smile
- upperLipThickness
- lowerLipThickness
- teethWhitening

Makeup:

- makeupIntensity
- lipstickIntensity
- blushIntensity
- eyebrowIntensity
- eyeshadowIntensity
- eyelinerIntensity

Filter:

- filterId
- filterIntensity
- brightness
- contrast
- saturation
- temperature
- tint
- sharpness

## 17.2 Parameter range recommendations

It is recommended to use uniform ranges for most parameters:

- 0 ~ 100: only enhanced parameters
- -100 ~ 100: Bidirectional adjustment parameters
- Bool: switch parameter
- Enum: type selection parameter
- String / ID: resource parameters, such as filter ID, makeup ID, sticker ID

Example:

- Big eyes: -100 ~ 100
- Eye distance: -100 ~ 100
- Face slimming: 0 ~ 100
- Microdermabrasion: 0 ~ 100
- Whitening: 0 ~ 100
- Mouth smile: 0 ~ 100

---

# 18. Product interface design suggestions

Although this is an SDK, a Demo App or integrator UI can refer to the following structure.

## 18.1 First level classification

Bottom level Tab:

1. Beauty
2. Face shape
3. facial features
4. Makeup
5. Filters
6. Stickers
7. Background
8. Style

## 18.2 Secondary classification

Remove it again under the facial features:

- eyes
- nose
- Mouth
- eyebrows
- Teeth
- Hairline

## 18.3 Parameter interaction

Recommended interactions:

- Horizontal function list
- A slider appears after clicking on the function
- Slider supports zeroing
- Support long press to view the original image
-Support before and after comparison
-Supports saving custom presets
-Supports one-click restoration to default

## 18.4 Advanced Mode

For professional users or internal parameter adjustment:

-Support independent adjustment for left and right eyes
-Support local point fine-tuning
-Support parameter JSON import and export
-Support parameter group saving
- Support A/B comparison

---

# 19. Feature priority suggestions

## 19.1 MVP Phase 1

Prioritize the implementation of the most core and user-perceived functions:

Basic beauty:

- Microdermabrasion
- Whitening
- ruddy
- Clarity

Face shape:

- face slimming
- small face
- V face
- Chin

Eyes:

- big eyes
- eye distance
- The upper and lower position of the eyes
- The tail of the eyes is raised
- Eye light

Nose:

- thin nose
- bridge of nose
- nose

Mouth:

- Mouth size
- smile
- lip color
- Teeth whitening

Filter:

- Basic filters
- Filter strength

Default:

- natural
- Clear
- Exquisite
- Boys are natural

## 19.2 Second phase

- Makeup system
- Wocan
- Color contact lenses
- Eyebrow adjustment
- Dark circles / nasolabial folds
- Individually adjust multiple faces
- Background blur
- LUT filter extension

## 19.3 The third stage

- Body beauty
- AR stickers
- AI stylization
- Background replacement
- Video high performance optimization
- Parameters are delivered to the cloud
- Commercial filters/makeup material package

---

# 20. Recommended core feature list

If you only build a relatively complete beauty SDK, it is recommended that the core capabilities include at least:

1. Microdermabrasion
2. Whitening
3. ruddy
4. Remove acne
5. Reduce dark circles
6. Face slimming
7. Small face
8. V face
9. Chin adjustment
10. Cheekbone adjustment
11. Big eyes
12. Eye distance adjustment
13. Adjust the up and down position of the eyes
14. Raised eyes
15. Lying silkworm
16. Eye light
17. Slim nose
18. Nose bridge adjustment
19. Nose adjustment
20. Nose adjustment
21. Mouth size
22. Smile
23. Lip color enhancement
24. Teeth Whitening
25. Eyebrow Shape
26. Eyebrow color
27. Makeup Templates
28. Partial makeup
29. Filters
30. Portrait segmentation
31. Background blur
32. Multi-face processing
33. Parameter preset
34. Parameter import and export
35. Real-time video processing
36. Image offline processing

---

# 21. Product Design Principles

## 21.1 Natural priority

Beauty should not only pursue intensity, but should prioritize naturalness.

It is recommended that each parameter have naturalness constraints internally:

- Avoid distortion of facial features.
- Avoid background stretching.
- Avoid obvious deformation of facial edges.
- Avoid inconsistent proportions of characters in group photos.

## 21.2 Parameters can be combined

Users often adjust not just one parameter, but a combination of multiple parameters.

Need to consider:

- Microdermabrasion + Clarity do not cancel each other out.
- Big eyes + distance between eyes + raised tail of eyes need to keep the eyes natural.
- For face slimming + chin + V face, you need to avoid having a face that is too pointed.
- Makeup + filters need to avoid oversaturated colors.

## 21.3 Real-time performance priority

As an SDK, you must pay attention to real-time preview performance.

Basic requirements:

- Support image processing.
- Support camera real-time preview.
- Support video frame processing.
- Support low-end machine downgrade strategy.
-Support different resolution output.

## 21.4 Configurable and extensible

The SDK should not hard-code all capabilities.

Recommended support:

- Distribution of configuration files.
- Filter resources are dynamically loaded.
-Dynamic loading of makeup materials.
- Parameter presets are dynamically loaded.
- Function modules are enabled on demand.

---

# 22. Documents that can be split later

You can continue to split it into the following documents:

1. "Beauty SDK Product Requirements Document PRD"
2. "Beauty SDK Function Parameter List"
3. "Beauty SDK Demo App UI Structure Design"
4. "Beauty SDK Face Key Points and Algorithm Capability Planning"
5. "Beauty SDK iOS Technical Architecture Design"
6. "Beauty SDK Filter and Makeup Resource Specifications"
7. "Beauty SDK External API Design Document"
8. "Beauty SDK Performance and Model Adaptation Plan"

