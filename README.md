# 🪶 Scout Code Generator

> Inspired by the Survey Corps (Attack on Titan)  
> Motto: "Membantu seluruh umat manusia"  
> Author: Widiyanto Ramadhan

[![pub package](https://img.shields.io/pub/v/scout_code_generator.svg)](https://pub.dev/packages/scout_code_generator)

Scout adalah code generator Flutter/Dart berprinsip Clean Architecture dan feature-based structure. Scout membantu membuat boilerplate Data/Domain/Usecase secara konsisten, termasuk impor otomatis, tipe pengembalian berbasis `Either<Failure, T>`, serta pemetaan Response → Entity.

---

## ✨ Fitur Utama
- `scout init`  
  Membuat file konfigurasi `scout_config.dart`.

- `scout make:feature <feature_name> "Author Name"`  
  Menghasilkan struktur folder awal untuk sebuah feature:
  - Data: `model/`, `datasource/`, `repository/`
  - Domain: `entity/`, `usecase/`
  - (Opsional) Presentation scaffolding

- Generator Usecase (interaktif)  
  Membuat lapisan berikut untuk sebuah usecase pada feature aktif:
  - Model: `data/model/request/*.dart` dan/atau `data/model/response/*.dart`
  - Datasource interface/impl: `data/datasource/`
  - Repository interface: `domain/repository/`
  - Repository implementation: `data/repository/`
  - Entity: `domain/entity/${snake}_entity.dart` (berdasarkan nama usecase/response)
  - Usecase interface & impl: `domain/usecase/`

---

## 🧭 Perilaku Generator (ringkas)
- __Imports otomatis__
  - Datasource mengimpor request/response model dari `../model/...`
  - Repository (domain) mengimpor `Either`, `Failure`, `entity`, dan request model (jika ada)
  - Repository impl (data) mengimpor datasource, `Either`, `Failure`, entity, dan request model (jika ada)
  - Usecase interface/impl (domain) mengimpor `Either`, `Failure`, entity (jika ada response), dan request model (jika ada)

- __Tipe pengembalian__
  - Semua method domain (repo dan usecase) memakai `Future<Either<Failure, T>>`
  - Untuk list: `Future<Either<Failure, List<T>>>`
  - Jika tidak ada response: `Future<Either<Failure, void>>`

- __Entity berbasis Response__
  - Nama file entity: `domain/entity/${snake}_entity.dart` (mengikuti nama usecase/response)
  - Class: `${Pascal}Entity` dan menyediakan `factory ${Pascal}Entity.fromResponse(${Pascal}Response response)`
  - Repository impl memetakan Response → Entity dengan `.fromResponse(...)`

- __Usecase `call()`__
  - Jika ada request: `Future<Either<Failure, T>> call({required ${Pascal}Request request})`
  - Jika tidak ada request: `Future<Either<Failure, T>> call()`
  - Usecase hanya meneruskan parameter ke repository (request dibuat di Controller/BLoC)

---

## ⚙️ Konfigurasi (`scout_config.dart`)
Contoh isi sederhana (path dapat disesuaikan):

```dart
class Config {
  final String features = 'lib/src/features';
  final String datasource = 'lib/src/features/features_name/data/datasource';
  final String model = 'lib/src/features/features_name/data/model';
  final String repository = 'lib/src/features/features_name/domain/repository';
  final String entity = 'lib/src/features/features_name/domain/entity';
  final String usecase = 'lib/src/features/features_name/domain/usecase';
}
```

Catatan: `features_name` akan diganti otomatis sesuai nama feature (snake_case).

---

## 🚀 Cara Pakai (singkat)
1) Instal di `pubspec.yaml`:

```yaml
dev_dependencies:
  scout_code_generator: ^0.0.1
```

2) Inisialisasi:

```bash
scout init
```

3) Buat feature:

```bash
scout make:feature example "Author Name"
```

4) Buat usecase (jalankan dalam konteks feature):

```bash
scout make:usecase feature_name usecase_name "Author Name"
```

Generator akan menanyakan beberapa input (mis. baseUrl jika belum ada, endpoint, HTTP method, dsb.). Jika request/response diperlukan, generator akan membuat model dan menautkan impor secara otomatis.

---

## 🧩 Konvensi Penamaan
- File: snake_case, Class: PascalCase
- Folder feature: `lib/.../features/<feature_snake>/...`

---

## ❓ FAQ singkat
- Request diisi di mana?  
  Di layer pemanggil (Controller/BLoC), lalu diteruskan ke `UseCase.call(...)`.

- Kenapa repository mengembalikan Entity?  
  Agar domain tidak tergantung pada DTO/Response data-layer. Mapping dilakukan di repository implementation.

---

## 📝 Lisensi
GPL-3.0-or-later
