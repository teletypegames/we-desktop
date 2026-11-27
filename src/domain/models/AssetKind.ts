/**
 * The asset kind of data an emulator boots — a `.prg`, a `.d64`, a `.tic`.
 *
 * WarpEngine 6.0 (WECP api 6) calls it `package`; an engine before it says `cartridge`.
 */
export const PACKAGE_KIND = 'package'

/** The kinds an older engine or an older store config spells differently. */
const KIND_ALIASES: Readonly<Record<string, string>> = { cartridge: PACKAGE_KIND }

/**
 * An asset kind by its WECP api 6 name: `cartridge` (api < 6) reads as `package`.
 *
 * The catalog's kinds and the config's both pass through here on the way in, so the
 * rest of the client compares one spelling and reads an old engine and a new one alike.
 */
export function canonicalAssetKind (kind: string): string {
  return KIND_ALIASES[kind] ?? kind
}
