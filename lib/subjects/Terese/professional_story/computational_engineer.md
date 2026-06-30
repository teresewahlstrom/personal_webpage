---
id: computational-engineer
title: Computational Engineer
category: MATH & LOGIC
short: Turning engineering reasoning into models, tools & automation
image: lib/subjects/Terese/assets/content/{theme}/capability/computational-engineer.png
order: 5
---

**Terese transforms engineering complexity into scalable analytical leverage. She focuses on turning complex engineering reasoning into structured, repeatable models, scripts, and computational tools.**

Throughout her career, Terese repeatedly encountered engineering problems that required the same reasoning to be performed over and over again: estimating costs, evaluating manufacturing constraints, preparing production builds, exploring design trade-offs, or assessing application suitability. She became interested in making the underlying reasoning explicit and programmatically reusable.

The governing logic behind many engineering problems is scattered across physical behavior, tacit assumptions, spreadsheets, and repetitive manual work. By translating that reasoning into models, scripts, and analysis tools, complex work becomes easier to scale, verify, and iterate upon.

The value comes from creating analytical leverage: capturing the reasoning that should be reused while keeping engineering judgment focused where interpretation, trade-offs, and validation are still required.

Whether the problem involved economics, geometry, manufacturing, or decision-making, the underlying challenge was often the same: important reasoning existed, but it had not yet been codified or structured.

Her approach follows a consistent pattern: **Abstract** - **Model** - **Compute** - **Validate**

* **Abstract:** Translate the physical or operational problem into relevant variables, constraints, and relationships.
* **Model:** Represent the governing logic mathematically, geometrically, or procedurally.
* **Compute:** Use analytical tools, scripts, or algorithms to evaluate options, or automate repetitive steps.
* **Validate:** Compare the output against engineering reality and refine the model where necessary.

## Computational engineering in practice

* **Production economics and cost modeling – GE Additive:** Evaluating production economics often required equipment utilization, production-cycle behavior, consumable demand, and machine configuration to be combined manually before meaningful trade-offs could be explored. Terese found that individual salespeople and departments often relied on their own ad hoc costing spreadsheets. Each encoded different assumptions about machine configuration, consumables, productivity, and production economics, leading to inconsistent estimates and customer recommendations. To make that reasoning explicit and reusable, she co-developed an Excel-based configuration, productivity, and cost model. Sales and application engineering used it to guide customer decisions, while internal teams used it to evaluate proposed R&D work before deciding which projects should be pursued. The model was also adapted and sold to customers for their own planning and decision-making.

* **Powder-reuse strategy and process modeling – GE Additive:** Through commercial and application-engineering work, she repeatedly encountered unrealistic assumptions about material demand, consumables consumption, configuration logic, and powder-reuse economics. Existing cost calculations often focused on the component itself while underrepresenting the surrounding powder, support material, and operational realities that influenced true material consumption. To establish a more realistic basis for decision-making, she developed process and powder-reuse models that allowed customers to evaluate how far powder reuse could responsibly be pushed while accounting for safety margins, scrap rates, packing density in vacuum environments, validation requirements, and regulatory constraints. This challenged both overly optimistic cost expectations and unnecessarily conservative single-use assumptions, helping customers identify more viable operating strategies and improve unit economics.

* **Geometry-driven build optimization – GE Additive:** After repeatedly performing nesting and stacking work that consumed significant time without adding engineering value, she independently designed rule-based geometric logic and implemented it in Python scripts. The tools respected thermal, spacing, and boundary constraints, reduced manual pre-build preparation, and allowed her to handle recurring production work more efficiently despite limited available resources.

* **Computational geometry – Volvo Cars, GE Additive, and Markforged:** She used geometry-driven workflows to create and adapt complex surface patterns, repeated motifs, Voronoi structures, and mathematically inspired geometries such as minimal surfaces, including Schwarz-P-type forms.
