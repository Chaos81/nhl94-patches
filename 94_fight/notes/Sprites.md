Sprites.anim file:

Stored in NHL92 at $3D5EE, it is $34B7E bytes in size. Last byte at $7216B (Start of Crowd.anim at $7216C).

First 2 bytes (41 41), ignore.
Next 2 bytes (02 24) = Number of frames - 1 (so $225 total frames, or 549 decimal).

Buildframelist - makes a table in ram of each frames starting point
    so as to have random access to sprite graphics

First frame data starts at byte 6. This address is saved in the #framelist.

SprStratt - offset $A: attribute flags
SprStrhot - offset $C: hotspot data (24 bytes)
SprStrnum - offset $24: # of sprites in this frame
SprStrdat - offset $26: start of sprite-entry list (8 bytes)
