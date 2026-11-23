{ buildGoModule }:
buildGoModule {
  pname = "atlas-to-kysely";
  version = "0.0.0";

  src = ./.;
  vendorHash = "sha256-bXUPYN1pAiRhp4gPBbQNQHnJSN8vrBZCeaDTh0iHcs4=";

  meta.mainProgram = "atlas-to-kysely";
}
