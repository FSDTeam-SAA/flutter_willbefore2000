# Keep Stripe classes
-keep class com.stripe.** { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# GSON rules (often used by Firebase/Plugins)
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeAdapter
-keep @com.google.gson.annotations.SerializedName class * { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }