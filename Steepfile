target :app do
  check "app"
  check "lib"
  signature "sig"

  # ActiveRecordモデルは動的属性が多く型検査に向かないため除外
  ignore "app/models/**/*.rb"
  ignore "sig/models/**/*.rbs"
end
