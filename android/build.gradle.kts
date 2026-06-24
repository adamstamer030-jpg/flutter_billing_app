allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Resetting custom build directory to use Gradle defaults. Having a custom build
// directory (pointing outside the project) breaks Flutter/CI artifact discovery
// and can cause "Gradle build failed to produce an .apk file" errors.
// See: https://github.com/flutter/flutter/issues/...

// The previous implementation redirected the build output to ../../build which
// prevents `flutter` tooling from locating generated APK/AAB artifacts. Use the
// default Gradle build directory instead by removing the custom buildDir logic.

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
