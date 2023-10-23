# URLLabel

This class lets you create a label that when clicked will open the url given to it.

![Screenshot of URL Label emo app](screenshots/URLLabel_example.png?raw=true "A screenshot of URL Labels render in the example project")


![Short gif showing label hover effect](screenshots/URLLabel_example2.gif?raw=true "A short gif of the label hover effect")


## Known Issues

### Title Flashing
The title text when the cursor first enters the label's bounding box, flashes (renders), then stops rendering until the delay time to show the title text is done.

### Hand cursor
The hand cursor is only shown on the first label to have a "tick", I supsect that this is a problem with how the cursor is determined and that it's a shared "system" property. Essentially a bug in my code.

### Hover color
Not yet implemented, the current color of the text when hovered is red. eventually this should/will be a parameter when creating the label.

### Bounds
The bounds of the label aren't recalculated when the following properties are modified:
* ~~size_enum~~ **<u>Immplemented</u>**
* size_px
* vertical_alignment_enum
* alignment_enum
* font
* anchor_x
* anchor_y