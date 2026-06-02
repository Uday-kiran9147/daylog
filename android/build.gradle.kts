allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = extensions.findByName("android") ?: return@withId
        if (name == "isar_flutter_libs") {
            androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                .invoke(androidExtension, "dev.isar.isar_flutter_libs")
        }
        try {
            androidExtension.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                .invoke(androidExtension, 34)
        } catch (e: Exception) {
            try {
                androidExtension.javaClass.getMethod("setCompileSdkVersion", String::class.java)
                    .invoke(androidExtension, "android-34")
            } catch (e2: Exception) {
                // ignore
            }
        }
    }
    project.evaluationDependsOn(":app")
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

