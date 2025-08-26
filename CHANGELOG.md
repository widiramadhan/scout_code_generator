## 0.0.1

Initial release.

- CLI: `scout init`, `scout make:feature <feature> "Author"`, `scout make:usecase <feature> <usecase> "Author"`
- Generates:
  - Data layer: models (request/response), datasource, repository_impl
  - Domain layer: entity (from response), repository (interfaces), usecase (interface & impl)
- Automatic import management with relative paths
- Domain returns `Future<Either<Failure, T>>` (single/list/void)
- Repository impl maps Response → Entity via `fromResponse`
