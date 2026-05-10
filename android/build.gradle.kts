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

// diabetes_model.tflite declares min_runtime_version 2.17.0; tflite_flutter pins 2.11.x.
subprojects {
    afterEvaluate {
        configurations.configureEach {
            resolutionStrategy {
                force("org.tensorflow:tensorflow-lite:2.17.0")
                force("org.tensorflow:tensorflow-lite-gpu:2.17.0")
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
