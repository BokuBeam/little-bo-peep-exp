# 26 June, 2023
## Title Bar
- Shrink title bar height
- Lower the logo's vertical alignment to better center its baseline
- Shrink the padding of the article title
- Remove useless arrow icon

## Cloud Position
- Fix font issues related to the math text being generated in a display:none element messing up the calculated font size
- Switch back to the grid layout for thought-clouds in the margins
  - Custom offsets are limited to large screen sizes to keep images from going off-screen or under the margin button on smaller screens.
  - I am hoping this doesn't reintroduce the paragraph spacing bug that occured before with phone rotation. I'm not able to reproduce that particular bug yet, so I'll need feedback on whether that has returned.
