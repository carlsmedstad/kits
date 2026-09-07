# kits

House rules for working on kits.

## Code comments

Do not add a comment by default. Prefer names and structure that make the code
clear without one.

Keep a comment only when it records a current constraint that is not evident
from the code and would surprise a competent reader, such as:

- a specification rule that makes the correct implementation look wrong;
- verified Git, Go, or platform behavior that defeats the obvious approach — Git
  discarding a trailer appended after the scissors marker, say;
- a non-obvious invariant needed to prevent a plausible regression.

Do not use comments to:

- restate the code or narrate its steps;
- explain language features, standard APIs, or established conventions;
- preserve implementation reasoning, rejected alternatives, or change history;
- duplicate the README, documentation, or specification;
- cite specification sections routinely.

Put rationale and history in the commit message. If history still constrains the
current code, state only the constraint that prevents the wrong simplification.

Cite the specification only when the code looks arbitrary without it and the
citation would change a maintainer's decision. Existing citations that protect
surprising behavior are not precedent for citing every function.

Keep required API documentation factual and brief. Put user-facing explanation
in the README.

Before finishing, review every comment added or changed. Delete it if the code
already says it; otherwise shorten it to the minimum needed to preserve the
constraint.

## Commits

Do not use Co-Authored-By trailers, use:

  Assisted-by: Claude-Code:<model>
