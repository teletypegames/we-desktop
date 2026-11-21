/**
 * The title a catalog entry was forked from, as the catalog names it.
 *
 * Only the two fields a person needs to find the parent: its name on its own engine and
 * that engine's base URL. Older engines say nothing about forks, and an entry from one
 * carries null rather than a guess.
 */
export interface ForkParent {
  /** The parent's `name` on its own engine. */
  readonly name: string
  /** The parent engine's base URL, as the catalog published it. */
  readonly engine: string
}
