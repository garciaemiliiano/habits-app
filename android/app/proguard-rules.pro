# Reglas para que R8/Proguard no rompa flutter_local_notifications.
# El plugin usa Gson con TypeTokens generic — sin estas reglas se cae
# en runtime con "Missing type parameter" al cancelar/agendar.

-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

-keep class com.dexterous.** { *; }
