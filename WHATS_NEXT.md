What's next
===========

[X] yield self from constructor

[X] "expand" config - merge every server config into servers, assign full path to each node

    Pick root node, create path stack, create server config stack
    pick child, push it's name to path stack, push it's default server config to path stack
    set child's path to reversed concatenated elements of path stack
    if child is a server - merge reversed default server configs stack, merge shared server configs and merge own config on top of that

    For all purposes except view having a list of servers from expanded tree is enough - gotta collect those


    [X] Make "path" assignable
    [X] Make config assignable for server
    [X] Make commands assignable to config in a convenient manner
    [X] Make the Expander
    [X] Make the Config hold shared server configs

[X] Extract command renderer from constructs/command (so command does not depend on server config). Maybe I don't need Command class altogether,
    not sure about what to do with description, though.

[X] Commands as part of server config

[X] Simplify creation of commands, sort module nesting out

[X] Make better api for creating and changing servers

[X] Make server config mutable - it's in the nature of this app, so it's ok

[ ] Refactor DSL2 (add specs first!)

[ ] Deal with shared server configs with arguments!
