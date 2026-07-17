# AdOps Real-Time Marketing Analytics Dashboard

A pixel-perfect, data-driven Flutter application designed from production Figma specs. The app monitors marketing campaign delivery, computes future performance via a Machine Learning regression forecast API, tracks channel spending distribution, and triggers alerts on real-time budget anomalies.

## 🚀 Key Architectural Pillars

- **Zero Hardcoded Core Philosophy:** Every progress bar math formulation, chart scaling index, data-legend percentage representation, and optimization advisory message is parsed dynamically from live network endpoints.
- **State Preservation via Shell Handling:** Employs an `IndexedStack` navigation layout wrapper to prevent Flutter from destroying and rebuilding views, preserving active data stream positions across tab selections.
- **State Management Engine:** Built on **Riverpod 2.x**, leveraging reactive `FutureProvider.family` and `StreamProvider` loops to isolate business logic cleanly from UI components.

---

## 🛠️ App Layout & Features

### 1. Campaigns Hub
- **Capsule Real-Time Search & Tab Filtering:** Instantly updates views locally against live collections using a reactive case-insensitive evaluation on string matches.
- **Dynamic Delivery Progress Bars:** Formulates safe mathematical tracking of actual variable expenditures against dynamic campaign budget caps (`(totalSpend / budget).clamp(0.0, 1.0)`).

### 2. Analytics & Performance Details
- **Seamless Hero Routing:** Integrates fluid shared-element structural transformations when tapping individual line elements to expand items seamlessly into active headers.
- **Predictive Performance Visualization:** Renders high-fidelity dual-line performance trends charting historical data directly alongside a shaded uncertainty band (`upper_bound`/`lower_bound`) via `fl_chart`.

### 3. Spend Summary Engine
- **Thick-Ring Channel Proportions:** Evaluates absolute spending across variable acquisition nodes on-the-fly to assign exact comparative segment weights within a dynamic donut layout.
- **Interactive Top Components Matrix:** Renders dynamic campaign rankings directly mapped with safe float scaling values (auto-converting floating-point decimals to fixed whole numbers).

### 4. Continuous Threat Monitoring
- **Automated API Polling Loop:** Instantiates a standalone `async*` generator ticking continuously every 30 seconds to fetch global snapshots, processing metric variance rules safely without halting background application state.

---

