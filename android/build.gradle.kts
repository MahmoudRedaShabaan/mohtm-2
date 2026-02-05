allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.12.2")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.2.10")
    }
}
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Ensure all Java compile tasks across included projects target Java 17.
// For Android projects the JavaCompile tasks must NOT use the --release flag
// because the Android Gradle plugin needs to set up the bootclasspath for
// compilation against Android APIs. For Android modules we set
// sourceCompatibility/targetCompatibility. For plain Java modules we set
// options.release to 17 where supported.
subprojects {
    tasks.withType(org.gradle.api.tasks.compile.JavaCompile::class.java).configureEach {
        options.encoding = "UTF-8"
        val isAndroidModule = project.plugins.hasPlugin("com.android.application") || project.plugins.hasPlugin("com.android.library")
        if (isAndroidModule) {
            // Use source/target for Android modules to avoid --release flag
            try {
                sourceCompatibility = JavaVersion.VERSION_17.toString()
                targetCompatibility = JavaVersion.VERSION_17.toString()
            } catch (_: Throwable) {
                // ignore; best-effort
            }
        } else {
            // For non-Android Java modules prefer the release flag when available
            try {
                options.release.set(17)
            } catch (_: Throwable) {
                try {
                    sourceCompatibility = JavaVersion.VERSION_17.toString()
                    targetCompatibility = JavaVersion.VERSION_17.toString()
                } catch (_: Throwable) {
                    // ignore
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
