#output dir
OUTDIR = "src"

# Package Name (Android only)
PKGNAME = "org.tmurakam.cashflow.models"

# class definitions

create_table :Assets, :class => :Asset, :base_class => :AssetBase do |t|
  t.text :name
  t.integer :type
  t.real :initialBalance
  t.integer :sorder
end

create_table :Transactions, :class => :Transaction, :base_class => :TransactionBase do |t|
  t.integer :asset
  t.integer :dst_asset
  t.date :date
  t.integer :type
  t.integer :category
  t.real :value
  t.text :description
  t.text :memo
end

create_table :Categories, :class => :Category do |t|
  t.text :name
  t.integer :sorder
end

create_table :DescLRUs, :class => :DescLRU do |t|
  t.text :description
  t.date :lastUse
  t.integer :category
end

