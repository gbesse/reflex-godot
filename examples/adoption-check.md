# reflex-godot — contrôle d’adoption · adoption check · comprobación de adopción

## Français

Point de départ local, après la préparation indiquée dans le README :

```sh
godot --headless --path . --quit
```

Dans le terrain de jeu, changez la révision d’un acteur avant de rejouer une action. La décision obsolète doit être refusée ; vérifiez le journal avec « Verify replay » dans Godot.

## English

Local starting point, after the setup described in the README:

```sh
godot --headless --path . --quit
```

In the playground, change an actor revision before replaying an action. The stale decision should be rejected; check the journal with “Verify replay” in Godot.

## Español

Punto de partida local, después de la preparación descrita en el README:

```sh
godot --headless --path . --quit
```

En el entorno de pruebas, cambie la revisión de un actor antes de repetir una acción. La decisión obsoleta debe rechazarse; compruebe el registro con «Verify replay» en Godot.
## Variante synthétique · Synthetic variation · Variante sintética

```text
actor_revision=2; proposed_action_revision=1
```

FR : adaptez une copie de la fixture locale à cette situation, puis vérifiez le comportement décrit ci-dessus. Les valeurs sont illustratives, pas des résultats Jev mesurés.

EN: adapt a copy of the local fixture to this situation, then check the behavior described above. Values are illustrative, not measured Jev output.

ES: adapte una copia de la fixture local a esta situación y compruebe el comportamiento descrito arriba. Los valores son ilustrativos, no resultados Jev medidos.
