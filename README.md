# Tetris Tutorial

This is the tetris tutorial for DragonRuby made by Ryan C. Gordon on YouTube

Part 1: [DragonRuby Tetris Tutorial Part 1][tutorial_part1]
Part 2: [DragonRuby Tetris Tutorial Part 2][tutorial_part2]

~~Though with very little modification, this is basically exactly what Mr. Gordon wrote in the tutorial.~~

Changes I've made/added:

- I added items as hashes instead of arrays and renamed a couple of local variables.
- I've added the ability to pause the game by pressing `P` on the keyboard or `Start` on a controller.
  - Pause hides the game board and next piece.
- I've added the ability to hold a piece by pressing `Q` on the keyboard or `Select` on a controller.
- Hold only allows switching out the piece once per block, so it's similar to other impelementations of Tetris

TODO:
  - Add support for showing piece statistics. (half done done, positioning of the text needs to be fixed)
  - Add support for various line clear statics (such as 1 to 3 and "Tetris" clear)
  - Add support for the game to speed up based on number of lines cleared

[tutorial_part1]: https://www.youtube.com/watch?v=xZMwRSbC4rY
[tutorial_part2]: https://www.youtube.com/watch?v=C3LLzDUDgz4