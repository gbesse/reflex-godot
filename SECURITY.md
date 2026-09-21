# Security scope

This alpha uses finite actions and local guards, but it is not a sandbox or multiplayer authority.

GDScript extensions are trusted executable code. Jev calls send world state externally. The direct environment-key adapter is for development only; a shipped client needs a server-side gateway. Errors are emitted through signals and the example reports them in the UI and Godot output. The embedding application owns administrator alerting.

Do not place secrets or personal data in public issues. Use GitHub's private vulnerability reporting when available, or contact the maintainer privately.
