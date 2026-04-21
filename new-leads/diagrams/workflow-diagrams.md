# Bana Land — New Leads Account: Workflow Diagrams
*Last edited: 2026-04-21 · Last reviewed: 2026-04-21*

Per-workflow internal-logic diagrams for the New Leads GHL sub-account. These are **informational** — [workflows.md](../workflows.md) remains the authoritative spec. If the diagrams drift from the spec, the spec wins.

Rendered with [Mermaid](https://mermaid.js.org/). Renders natively in VS Code's markdown preview and on GitHub.

---

## WF-New-Lead-Entry | New Lead Entry

Spec: [workflows.md:44-78](../workflows.md#L44-L78)

```mermaid
flowchart TD
  T["<b>Trigger</b><br/>Contact added to<br/>Acquisition: New Leads"] --> RS{"re-submitted<br/>tag present?"}

  RS -->|Yes| DNC{"DNC?<br/>dnc tag OR<br/>Lost Reason = DNC"}
  DNC -->|Yes| BLOCK["Notify internal:<br/>'Re-submission blocked — DNC'<br/><b>End workflow</b>"]
  DNC -->|No| CLEAN["<b>Cleanup</b><br/>• Remove from 6 WFs:<br/>  Day 1-10, Day 11-30,<br/>  Cold Drip, Nurture,<br/>  LT Quarterly, Dispo Re-Engage<br/>• If Opp status = Lost →<br/>  clear Lost Reason, set Open<br/>• Clear 'Pause WFs Until'<br/>• Remove 're-submitted' tag"]

  RS -->|No| ASSIGN
  CLEAN --> ASSIGN{"Latest Source?"}

  ASSIGN -->|Cold SMS<br/>Cold Call| LM["Assign owner:<br/><b>Lead Manager</b>"]
  ASSIGN -->|Direct Mail<br/>VAPI<br/>Referral<br/>Website| AM["Assign owner:<br/><b>Jeremy + AM2</b><br/>round-robin, split equally"]

  LM --> SRC["<b>Update Contact native Source</b><br/>(skip if already set —<br/>first-touch attribution)<br/><br/><i>Opp native Source, Latest Source,<br/>and Latest Source Date are set<br/>by n8n during intake</i>"]
  AM --> SRC

  SRC --> NOTIFY["<b>Notify assigned owner</b><br/>• Internal notification<br/>• GHL mobile push<br/>• Internal SMS to personal #"]

  NOTIFY --> BR{"Latest Source?"}

  BR -->|Cold SMS<br/>Cold Call| A["<b>Branch A — Cold outbound</b><br/>Wait 120s → SMS CO-SMS-00<br/>Wait 1h → if no call logged →<br/>SMS CO-SMS-00A (missed call)"]
  BR -->|Website<br/>VAPI<br/>Referral| B["<b>Branch B — Inbound</b><br/>Wait 120s → SMS IN-SMS-00<br/>Wait 1h → if no call logged →<br/>SMS IN-SMS-00A (missed call)"]
  BR -->|Direct Mail| C["<b>Branch C — Direct Mail</b><br/>Wait 120s → SMS DM-SMS-00<br/>Wait 1h → if no call logged →<br/>SMS DM-SMS-00A (missed call)"]

  A --> EXIT["<b>Exit</b><br/>Owner works lead on Day 0,<br/>then manually moves to Day 1-10<br/>→ triggers WF-Day-1-10"]
  B --> EXIT
  C --> EXIT

  classDef trigger fill:#1a4d3a,stroke:#2d8660,color:#fff
  classDef decision fill:#3d3620,stroke:#8a7838,color:#fff
  classDef action fill:#1f2d3d,stroke:#4a6a8a,color:#fff
  classDef terminal fill:#4a1f2d,stroke:#8a4a5a,color:#fff
  classDef exit fill:#2d4a1f,stroke:#5a8a4a,color:#fff

  class T trigger
  class RS,DNC,ASSIGN,BR decision
  class CLEAN,LM,AM,SRC,NOTIFY,A,B,C action
  class BLOCK terminal
  class EXIT exit
```

**Legend:**
- <span style="color:#2d8660">■</span> Trigger — workflow entry
- <span style="color:#8a7838">◆</span> Decision — branch point
- <span style="color:#4a6a8a">■</span> Action — state change or side effect
- <span style="color:#8a4a5a">■</span> Terminal — workflow ends here
- <span style="color:#5a8a4a">■</span> Exit — hands off to next workflow

**Key behaviors:**
- **Re-submission cleanup is conditional on non-DNC.** If DNC is detected, the workflow ends immediately without cleanup — DNC state is permanent and must not be cleared.
- **Owner assignment uses "Only Apply to Unassigned Contacts"** so re-submitted leads keep their existing owner (see spec step 2).
- **Source fields are owned by n8n**, not this workflow. n8n sets Opportunity native Source (create only, first-touch), Latest Source, and Latest Source Date on every intake (create + re-submit). This workflow only sets **Contact native Source** as a first-touch mirror, because n8n's `contact_payload` doesn't include it.
- **Day 0 SMS branches are mutually exclusive** — a lead hits exactly one of A / B / C based on Latest Source.

---

*More workflow diagrams will be added here as needed. Current priority order for future diagrams: WF-Response-Handler (re-engagement branching), WF-Dispo-Re-Engage (Lost Reason branching), WF-Day-11-30 (RVM timing).*
