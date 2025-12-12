# --- ProGuard Rules for Missing Classes (R8 Fix) ---

# Keep all classes related to JAI ImageIO (Java Advanced Imaging Image I/O Tools)
# Ini menjaga kelas-kelas yang terkait dengan pemrosesan gambar yang hilang
-keep class com.github.jaiimageio.** { *; }

# Keep all classes related to imageio SPI interfaces
-keep class javax.imageio.spi.** { *; }

# Keep all classes related to imageio readers and writers
-keep class javax.imageio.** { *; }

# Jika Anda mengidentifikasi library yang spesifik, tambahkan rule untuk library tersebut.
# Contoh: Jika Anda menggunakan library QR/Barcode scanner yang memiliki masalah serupa
# -keep class com.google.zxing.** { *; } 

# ---------------------------------------------------