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
        if (name == "isar_flutter_libs") {
            val androidExtension = extensions.findByName("android") ?: return@withId
            androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                .invoke(androidExtension, "dev.isar.isar_flutter_libs")
        }
    }
    project.evaluationDependsOn(":app")
}
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

