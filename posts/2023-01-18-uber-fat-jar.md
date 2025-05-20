---

title:  "Uber or Fat jar"
categories: java
---

## What is uber/fat jar?

An "uber jar" (also known as a "fat jar" or "shadow jar") is a single executable Java archive that contains all of the dependencies needed to run a Java application, including the application's code and resources. It is called "uber" because it is a standalone jar that can be executed without the need for additional dependencies.

## Use SBT

To create a "fat jar" with sbt, you can use the sbt-assembly plugin. This plugin allows you to package all of your application's dependencies and classes into a single executable jar.

To use the sbt-assembly plugin, you will first need to add it to your project's build.sbt file:

```
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.14.10")
```

Then, you can use the `assembly` command to create the fat jar.

For example, to create a fat jar for your project, you can run the following command in the project's root directory:

```
sbt assembly
```

This will create a jar file in the `target/scala-<version>/` directory that contains all of your project's dependencies and classes.

You can also configure the plugin to exclude some specific dependency or add some custom merge strategy to handle conflicts between dependencies.

You can also configure the main class of the jar, so that you can execute your jar with java -jar command.

```
mainClass in assembly := Some("com.example.Main")
```

This is a common way to create a fat jar using sbt, but you can also use other plugins or custom tasks if you have specific requirements.