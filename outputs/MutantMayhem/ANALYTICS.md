# Structured analytics

Events are JSON lines prefixed `[MM]`, with `event`, numeric `userId`, Unix `time`, and `fields`. AnalyticsService retains the latest 200 events in memory. This is a development log, not a deployed analytics warehouse.

| Event | Fields / use |
|---|---|
| server_ready | plots, demo, ownershipTheft feature gate |
| session_start | visit number, demo/durable mode; visit > 1 indicates a returning saved profile |
| session_end | elapsed seconds for the observed session |
| first_creature | time-to-first-collectible relative to session_start |
| creature_discovered | archetype number |
| first_mutation | onboarding funnel |
| mutation_roll | seed, complete descriptor, ordinal roll, earned-coin cost; server log of every roll |
| tutorial_complete | emitted after the shield tutorial step |
| economy_source | collect / missions, amount |
| economy_sink | discovery / cosmetic / research, amount and research rank if applicable |
| plot_upgrade | tier and cost |
| prestige | mastery level |
| daily_reward | amount including capped catch-up |
| theft_attempt | defender ID; explicitly marked non_destructive_DNA |
| dna_raid_complete | sample delivered |
| shop_view | deliberate navigation to Style page |
| purchase_durable | product ID and receipt ID; receipt re-delivery may emit this log again, so deduplicate by purchase ID |
| load_failed / save_failed | error and release flag; operational diagnostics |
| receipt_grant_error / action_error | error details |

When a real sink is connected, exclude demo traffic, deduplicate purchase events, and define acquisition-day cohorts before calculating D1/D7 return rates. Compute session duration from real sessions and conversion from distinct confirmed purchaser IDs / eligible player IDs. No retention, monetization, or engagement result is claimed from synthetic tests.
