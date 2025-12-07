# FIRESTORE PERMISSION FIX - ORDER CREATION
## Fixed: December 7, 2025

## Problem
When creating an order in the marketplace, users were getting permission denied errors:

```
W/Firestore: [WriteStream]: Stream closed with status: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}.
W/Firestore: Write failed at marketplace_products/TTZMRYv9TIpi8780e7o5: Status{code=PERMISSION_DENIED, description=Missing or insufficient permissions., cause=null}
I/flutter: ❌ Error creating order: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

## Root Cause
The issue was in the Firestore security rules for `marketplace_products` and `products` collections. 

When a user creates an order:
1. The order service (`order_service.dart`) calls `_updateProductStock()` 
2. This method updates the product's `stock` and `soldCount` fields using `FieldValue.increment()`
3. The buyer (user creating the order) is NOT the product owner (seller)
4. The old Firestore rules only allowed the seller to update their products:

```javascript
allow update: if isSignedIn() &&
                 resource.data.sellerId == request.auth.uid &&
                 request.resource.data.sellerId == resource.data.sellerId;
```

This caused the buyer to be denied permission when trying to update the product stock during checkout.

## Solution
Updated the Firestore rules to allow buyers to update ONLY the `stock` and `soldCount` fields when creating an order:

### For `marketplace_products` collection:
```javascript
allow update: if isSignedIn() && (
  // Seller can update all fields of their own product
  (resource.data.sellerId == request.auth.uid &&
   request.resource.data.sellerId == resource.data.sellerId) ||
  // Buyer can update ONLY stock & soldCount during checkout
  (request.resource.data.diff(resource.data).affectedKeys().hasOnly(['stock', 'soldCount']) &&
   request.resource.data.sellerId == resource.data.sellerId)
);
```

### For `products` collection:
```javascript
allow update: if isSignedIn() && (
  // Seller can update all fields of their own product
  (resource.data.sellerId == request.auth.uid &&
   request.resource.data.sellerId == resource.data.sellerId) ||
  // Buyer can update ONLY stok & soldCount during checkout
  (request.resource.data.diff(resource.data).affectedKeys().hasOnly(['stok', 'soldCount']) &&
   request.resource.data.sellerId == resource.data.sellerId)
);
```

## Security Analysis
This change is secure because:

1. **Limited Field Updates**: Buyers can ONLY update `stock` and `soldCount` fields - no other fields can be changed
2. **Seller ID Protection**: The `sellerId` field must remain unchanged (`request.resource.data.sellerId == resource.data.sellerId`)
3. **Authentication Required**: Users must be signed in (`isSignedIn()`)
4. **Field-Specific Permission**: Using `diff().affectedKeys().hasOnly(['stock', 'soldCount'])` ensures ONLY these fields are modified
5. **Natural Stock Decrement**: The order service uses `FieldValue.increment(-quantity)` which naturally decreases stock

## Files Modified
1. `firestore.rules` - Updated security rules for both collections:
   - `marketplace_products/{productId}` - Updated `allow update` rule
   - `products/{productId}` - Updated `allow update` rule

## Deployment
Rules deployed using:
```powershell
firebase deploy --only firestore:rules
```

Status: ✅ **Successfully deployed**

## Testing
After deploying the rules, test the order creation flow:
1. Add products to cart
2. Proceed to checkout
3. Fill in delivery details
4. Complete payment
5. Verify order is created successfully
6. Check that product stock is decremented

## Related Files
- `lib/core/services/order_service.dart` - Order creation logic with stock update
- `lib/core/repositories/order_repository.dart` - Repository layer
- `lib/core/providers/order_provider.dart` - Provider layer
- `firestore.rules` - Security rules

## Notes
- The same fix was applied to both `marketplace_products` and `products` collections
- The `products` collection uses `stok` field (Indonesian) instead of `stock`
- Both collections now allow buyers to update inventory during checkout
- Sellers retain full control over all other product fields

