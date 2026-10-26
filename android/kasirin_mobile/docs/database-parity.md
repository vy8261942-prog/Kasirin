# Database Parity

## Source and Status

- Desktop schema: `../../app/models/entities.py`, imported by `../../app/models/__init__.py`.
- SQLite behavior: `../../app/core/database.py` enables foreign keys, WAL and a 5-second busy timeout.
- Alembic chain: `../../migrations/versions/`, from `c3e517177866` through observed head `20261018_02`.
- Desktop storage is local SQLite. Mobile storage must be a separate app-private SQLite database; POS data is not sent to `billing_server`.
- Drift definitions, migrations, import compatibility and mobile migration tests are **not implemented**. This is a porting inventory, not a parity claim.

The inventory records the active ORM's declared columns. `id` is an integer primary key unless noted. `created_at` and `updated_at` are non-null UTC-aware timestamps on `TimestampMixin` tables; `deleted_at` is nullable on `SoftDeleteMixin` tables. Python booleans map to SQLite integers. Money and quantities are integer columns except wholesale `discount_percent` (`Numeric(5,2)`).

## Tables

| Table | Declared columns (plus applicable mixins) | Constraints / indexes / relationships |
|---|---|---|
| `role_permissions` | `role_id`, `permission_id` | Composite primary key; both FKs cascade on delete |
| `roles` | `id`, `name`, `description` | `name` unique |
| `users` | `id`, `username`, `full_name`, `whatsapp`, `password_hash`, `role_id`, `is_active`, `failed_login_count`, `locked_until`, `last_login_at`, `must_change_password` | `username` unique + indexed; role FK |
| `stores` | `id`, `code`, `name`, `slogan`, `address`, `whatsapp`, `logo_path` | `code` unique |
| `payment_settings` | `id`, `cash_enabled`, `qris_dana_enabled`, `qris_midtrans_enabled`, `transfer_enabled` | Flags; cash defaults true, others false |
| `payment_wizard_states` | `id`, `method`, `status`, `payload` | `method` unique |
| `categories` | `id`, `name` | `name` unique |
| `units` | `id`, `name`, `symbol` | `name` unique |
| `products` | `id`, `sku`, `barcode`, `name`, `category_id`, `unit_id`, `supplier_id`, `purchase_price`, `selling_price`, `stock_qty`, `min_stock`, `is_active` | SKU unique + indexed; nullable barcode unique + indexed; category/unit/supplier FKs |
| `login_history` | `id`, `user_id`, `login_at` | `user_id` and `login_at` indexed; user FK |
| `inventaris_toko` | `id`, `kode_inventaris`, `nama_barang`, `jumlah`, `satuan`, `tanggal_perolehan`, `harga_perolehan`, `lokasi`, `kondisi`, `keterangan` | `kode_inventaris` unique + indexed |
| `bulk_price_rules` | `id`, `product_id`, `quantity_threshold`, `discount_percent`, `special_price`, `pricing_mode` | Unique `(product_id, quantity_threshold)`; threshold >= 1; percent > 0 and <= 100; price >= 0; mode `PRICE`/`PERCENT`; product FK cascades |
| `shifts` | `id`, `store_id`, `cashier_id`, `opened_at`, `closed_at`, `opening_cash`, `closing_cash`, `status` | Store/cashier FKs |
| `customers` | `id`, `code`, `name`, `phone` | `code` unique |
| `suppliers` | `id`, `code`, `name`, `phone`, `address` | `code` unique |
| `sales` | `id`, `invoice_no`, `store_id`, `shift_id`, `cashier_id`, `customer_id`, `subtotal`, `discount`, `tax`, `grand_total`, `status` | Invoice unique; store/shift/cashier/customer FKs |
| `cashier_daily_reports` | `id`, `cashier_id`, `report_date`, `sales_count`, `sales_total`, `notes` | Unique `(cashier_id, report_date)`; count/total >= 0; date indexed; cashier FK |
| `sale_items` | `id`, `sale_id`, `product_id`, `qty`, `unit_price`, `unit_cost`, `discount`, `line_total` | Sale/product FKs |
| `payments` | `id`, `sale_id`, `method`, `amount`, `reference` | Sale FK |
| `stock_movements` | `id`, `product_id`, `movement_type`, `stock_before`, `qty`, `stock_after`, `reference_type`, `reference_id`, `note` | Product FK |
| `payment_methods` | `id`, `code`, `name`, `is_active` | `code` unique; soft delete |
| `permissions` | `id`, `code`, `name`, `description` | `code` unique |
| `price_lists` | `id`, `code`, `name`, `starts_at`, `ends_at`, `is_active` | `code` unique; soft delete |
| `price_list_items` | `id`, `price_list_id`, `product_id`, `price` | Unique `(price_list_id, product_id)`; price >= 0; price-list FK cascades; product FK |
| `promotions` | `id`, `code`, `name`, `description`, `discount_type`, `discount_value`, `product_id`, `category_id`, `starts_at`, `ends_at`, `is_active` | Code unique; type `AMOUNT`/`PERCENT`; value > 0 and percent <= 100; end >= start; nullable product/category FKs; soft delete |
| `purchase_orders` | `id`, `order_no`, `supplier_id`, `store_id`, `created_by`, `status`, `ordered_at`, `expected_at`, `subtotal`, `payment_status`, `due_date`, `paid_amount`, `notes` | Order unique; subtotal >= 0; status `PAID`/`TEMPO`/`DP`; paid in [0,subtotal]; payment-term consistency check; supplier/store/user FKs |
| `purchase_order_items` | `id`, `purchase_order_id`, `product_id`, `ordered_qty`, `received_qty`, `unit_cost` | Ordered qty > 0; received qty/cost >= 0; purchase FK cascades; product FK |
| `stock_opnames` | `id`, `opname_no`, `store_id`, `counted_by`, `status`, `counted_at`, `notes` | Opname number unique; store/user FKs |
| `stock_opname_items` | `id`, `stock_opname_id`, `product_id`, `system_qty`, `counted_qty`, `notes` | Unique `(stock_opname_id, product_id)`; quantities >= 0; opname FK cascades; product FK |
| `expenses` | `id`, `shift_id`, `recorded_by`, `category`, `amount`, `paid_amount`, `payment_status`, `due_date`, `payee`, `account_id`, `incurred_at`, `description` | Amount > 0; status `CASH`/`HUTANG`/`DP`; nullable shift/account FKs; user FK |
| `accounts` | `id`, `code`, `name`, `account_type`, `is_active`, `is_system` | Code unique; type in `ASSET`, `LIABILITY`, `EQUITY`, `REVENUE`, `EXPENSE` |
| `financial_settings` | `id`, `effective_from`, `initialized_by`, `initialized_at` | Nullable user FK; singleton convention id 1 |
| `journal_entries` | `id`, `entry_date`, `source_type`, `source_id`, `memo`, `posted_by` | Unique `(source_type, source_id)`; date indexed; posted-by FK; lines cascade in ORM relationship |
| `journal_lines` | `id`, `journal_entry_id`, `account_id`, `debit`, `credit`, `description` | Entry FK cascades + indexed; account FK; exactly one positive side |
| `financial_payments` | `id`, `purchase_order_id`, `expense_id`, `account_id`, `amount`, `payment_method`, `paid_at`, `created_by` | Amount > 0; exactly one purchase/expense FK set; document FKs indexed; account/user FKs |
| `cash_transactions` | `id`, `shift_id`, `transaction_type`, `amount`, `description` | Shift FK |
| `audit_logs` | `id`, `user_id`, `action`, `entity_type`, `entity_id`, `detail` | Nullable user FK |

## Transaction and Migration Requirements

- Preserve checkout in `../../app/services/sales_service.py`: sale, items, payments, stock changes, stock movements, financial journal and audit log commit atomically; any error rolls back all writes.
- Recompute tier prices at commit from current rules. Desktop allows at most three tiers, selects the greatest reached threshold, and rounds percentage-derived Rupiah using decimal half-up.
- Preserve 64-bit integer money, UTC timestamps, null/default behavior, constraints, indexes, FKs and soft-delete columns.
- Use ordered, non-destructive Drift migrations. Never use destructive migration fallback. Add schema/upgrade tests on Android and iOS before claiming parity.
- Desktop password hashes use Argon2 (`../../app/core/security.py`). Mobile must verify compatible hashes or rehash only after successful authentication; never reset silently.
- Do not copy desktop DB files or sync POS rows to billing. Import/export needs a sanitized fixture and explicit compatibility policy.

## Current Mobile Implementation

- `lib/data/local_database.dart` currently declares the desktop table names using hand-written SQL, not Drift `Table` declarations. It contains the 36 listed desktop table names and is schema version 1; `allTables` and `allSchemaEntities` are empty.
- A fresh database runs the complete create-statement list. There is no ordered post-v1 migration yet, no migration fixture/test, and no destructive fallback. Any future schema change must add an explicit migration and upgrade test before release.
- Mobile-only schema differences still need a column/constraint comparison against the ORM. In particular, desktop service validation such as maximum wholesale tier count and permission decisions is not guaranteed by current SQLite constraints.
- The repository writes sale, sale items, payments, stock quantity/movement, balanced journal rows and audit log inside one Drift database transaction. Invoice number is the retry key. Repository tests cover rollback, one-time stock mutation, retry, tier price and unknown cost behavior; Flutter test execution is pending.
- The cashier UI accepts CASH only. It does not imply parity for desktop payment methods, customer, discount, tax, refunds, shift close, reports, purchase, or finance flows.
- The mobile app creates a fresh local database. Desktop Argon2 password hashes cannot currently be authenticated by the mobile PBKDF2 verifier; no automatic import or hash reset is performed.

Do not claim migration parity or existing desktop-database compatibility until schema diffing, non-destructive migration tests, and sanitized import/export fixtures exist.

Verified here: ORM table/column inventory, model-declared constraints/FKs/indexes, desktop SQLite pragmas, and observed Alembic head. Outstanding: Drift definitions/codegen, SQLite affinity checks, upgrade/import tests, and rollback tests on both platforms.