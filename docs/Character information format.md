![alt text](images/logo2.png)

Character information is stored in a binary file that is stored inside **character cards**, which are images that represent the character's appearance, and include a nice frame alongside with some visual indicatives of the character's personality.

Users can freely share cards with their friends, and on arrival they will contain the information of that character.

# Steganography
Binary card information is really just a vessel, a container to store the main json file and all the data needed to decompress it (because it's compressed, more on that later) while it's inside an image file, so **in practice it's never used outside images**.

The data is stored only in the red green and blue channels, **not in the alpha**, in fact when the game loads cards it discards the alpha channel from the image (cards shouldn't really have an alpha channel), reading the data should be simply done sequentially (R G B R G B ...) and only the two least significant bits should be read.

The format used by the game for cards is RGB8 internally (RGBA8 when saved to disk because PNG).

# Character format specification
| Position | Name | Description |
|--|--|--|
| 0x0 - 0x03 | Start marker (ERO1) | Marks where the character file starts |
| 0x4 | File version | Character file format version (currently 1) |
| 0x5-0x8 | Length of the uncompressed data information | Contains the size in bytes of the json file before being compressed (it's a 32 bit integer) |
| 0x9 - ? | Compressed data | Contains the compressed json file |
| ? - EOF | Ending marker (EROE) | Marks the end of the file |
# The compressed data sector
The compressed data sector contains a json file which is the actual character information, this is done in order to save space (previously we used to save the json info in plaintext after the png IEND marker, that was a disaster of biblical proportions because when uploading it to hosting services such as imgur the information would be stripped).

The compressed data sector uses ZStandard for compression.
