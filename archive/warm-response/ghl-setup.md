# Bana Land — Warm Response Account: GHL Setup Guide

**Status: PLACEHOLDER — No active workflows, no pipeline, no contacts.**

All Warm Response workflows (WF-00A, WF-00B, WF-05, WF-10, WF-HANDOFF, WF-11, WF-CLEANUP) have been merged into [New Leads](../new-leads/ghl-setup.md) or eliminated. This account is kept as an empty placeholder for potential future use (backup phone numbers, sender reputation protection if needed).

**What was eliminated:**
- WF-HANDOFF — no cross-account transfer needed (single account)
- WF-CLEANUP — no cross-account cleanup needed
- WF-00B (SMS Track) — Cold SMS leads now enter New Leads directly, follow standard Day 1-30 sequence
- Cross-account DNC sync (WR ↔ NL) — single account, one DNC workflow handles it

**What moved to New Leads:**
- WF-00A (Email Track) → New Leads WF-00A (Cold Email Sub-Flow)
- WF-05 (Cold Drip) → Already existed in New Leads as WF-05, now handles all sources
- WF-10 (DNC) → Already existed in New Leads as WF-10, simplified to NL ↔ Prospect Data
- WF-11 (Response Handler) → Already existed in New Leads as WF-11, updated for dual-owner model
