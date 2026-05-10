package com.example;

import org.apache.camel.main.Main;

/**
 * Entry point — Camel Main auto-discovers routes from
 * src/main/resources/camel/*.yaml on the classpath.
 */
public class CamelApp {
    public static void main(String[] args) throws Exception {
        new Main().run(args);
    }
}
