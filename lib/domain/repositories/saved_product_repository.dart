//external and internal db calls for bookmark functionality
abstract class SavedProductRepository {
  Future<void> initLocalDb();
  Future<void> insertInLocalDb(String prodId);
  Future<void> deleteFromLocalDb(String prodId);
  Future<bool> isSaved(String prodId);
  Future<void> removeSavedProduct(String prodId);
  Future<bool> saveProduct(String prodId);
}
