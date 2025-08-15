package org.example;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;

public class JarClassReplacer {
    public static void main(String[] args) {
        try {
            // 示例用法
            String jarPath = "C:\\Program Files (x86)\\Steam\\steamapps\\common\\SlayTheSpire\\desktop-1.0.jar";          // 原始JAR包路径
            List<ReC> newClassPaths = new ArrayList<>();
            newClassPaths.add(new ReC(
                    "com/megacrit/cardcrawl/cards/red/Strike_Red.class", // 要替换的类名(包含包路径)
                    "target/classes/com/megacrit/cardcrawl/cards/red/Strike_Red.class"  // 新的class文件路径
            ));
            newClassPaths.add(new ReC(
                    "com/megacrit/cardcrawl/cards/red/Defend_Red.class",
                    "target/classes/com/megacrit/cardcrawl/cards/red/Defend_Red.class"
            ));
            String outputJarPath = "desktop-1.0.jar";    // 输出的新JAR包路径

            replaceClassInJar(jarPath, newClassPaths, outputJarPath);
            System.out.println("Class文件替换成功！");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * 替换JAR包中的class文件
     *
     * @param jarFilePath   JAR包路径
     * @param reCList       新/旧的class文件路径
     * @param outputJarPath 输出的新JAR包路径
     * @throws IOException 处理过程中发生的IO异常
     */
    @SuppressWarnings("ResultOfMethodCallIgnored")
    public static void replaceClassInJar(String jarFilePath, List<ReC> reCList, String outputJarPath) throws IOException {
        // 创建临时目录用于解压JAR包
        File tempDir = new File("temp_jar_extract");
        if (!tempDir.exists() && tempDir.mkdir()) {
            System.out.println("临时目录已创建");
        }

        try (JarFile jarFile = new JarFile(jarFilePath)) {
            // 解压JAR包到临时目录
            Enumeration<JarEntry> entries = jarFile.entries();
            while (entries.hasMoreElements()) {
                JarEntry entry = entries.nextElement();
                File entryFile = new File(tempDir, entry.getName());

                if (entry.isDirectory()) {
                    entryFile.mkdirs();
                } else {
                    // 确保父目录存在
                    entryFile.getParentFile().mkdirs();

                    // 复制文件内容
                    try (InputStream in = jarFile.getInputStream(entry);
                         OutputStream out = Files.newOutputStream(entryFile.toPath())) {
                        byte[] buffer = new byte[1024];
                        int bytesRead;
                        while ((bytesRead = in.read(buffer)) != -1) {
                            out.write(buffer, 0, bytesRead);
                        }
                    }
                }
            }
        }
        for (ReC reC : reCList) {
            // 替换class文件
            File newClassFile = new File(reC.getNewClass());
            File destClassFile = new File(tempDir, reC.getOldClass());
            // 确保目标目录存在
            if (!destClassFile.getParentFile().exists()) {
                System.out.println("出现异常：目标文件夹不存在");
                return;
            }
            // 复制新的class文件到临时目录中的对应位置
            try (InputStream in = Files.newInputStream(newClassFile.toPath());
                 OutputStream out = Files.newOutputStream(destClassFile.toPath())) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = in.read(buffer)) != -1) {
                    out.write(buffer, 0, bytesRead);
                }
            }
        }

        // 重新打包成JAR文件
        try (JarOutputStream jarOut = new JarOutputStream(Files.newOutputStream(Paths.get(outputJarPath)))) {
            addFilesToJar(tempDir, tempDir, jarOut);
        }

        // 清理临时文件
        deleteDirectory(tempDir);

    }

    /**
     * 将目录中的文件添加到JAR输出流
     */
    private static void addFilesToJar(File rootDir, File currentDir, JarOutputStream jarOut) throws IOException {
        File[] files = currentDir.listFiles();
        if (files == null) {
            return;
        }

        for (File file : files) {
            if (file.isDirectory()) {
                addFilesToJar(rootDir, file, jarOut);
            } else {
                // 计算相对路径作为JAR中的条目名
                String entryName = rootDir.toURI().relativize(file.toURI()).getPath();
                JarEntry entry = new JarEntry(entryName);
                jarOut.putNextEntry(entry);

                try (InputStream in = Files.newInputStream(file.toPath())) {
                    byte[] buffer = new byte[1024];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {
                        jarOut.write(buffer, 0, bytesRead);
                    }
                }
                jarOut.closeEntry();
            }
        }
    }

    /**
     * 删除目录及其内容
     */
    @SuppressWarnings("ResultOfMethodCallIgnored")
    private static void deleteDirectory(File directory) {
        if (directory == null || !directory.exists()) {
            return;
        }

        File[] files = directory.listFiles();
        if (files != null) {
            for (File file : files) {
                if (file.isDirectory()) {
                    deleteDirectory(file);
                } else {
                    file.delete();
                }
            }
        }

        directory.delete();
    }
}

