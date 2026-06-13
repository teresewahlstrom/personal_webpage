// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  print('🚀 Starting hydrated_seo pre-rendering pipeline...');

  // 1. Load configurations
  final configFile = File('seo_config.yaml');
  List<String> routes = ['/'];
  String outputDir = 'build/web';
  int renderDelayMs = 1500;
  String? siteUrl;

  if (configFile.existsSync()) {
    try {
      final yamlContent = loadYaml(configFile.readAsStringSync());
      if (yamlContent != null) {
        if (yamlContent['routes'] is List) {
          routes = List<String>.from(yamlContent['routes']);
        }
        if (yamlContent['output_dir'] is String) {
          outputDir = yamlContent['output_dir'];
        }
        if (yamlContent['render_delay_ms'] is int) {
          renderDelayMs = yamlContent['render_delay_ms'];
        }
        if (yamlContent['site_url'] is String) {
          siteUrl = yamlContent['site_url'];
        }
      }
      print('📖 Loaded config from seo_config.yaml');
    } catch (e) {
      print('⚠️ Error parsing seo_config.yaml, using defaults. Details: $e');
    }
  } else {
    print('ℹ️ No seo_config.yaml found, using default configurations.');
  }

  final outputDirectory = Directory(outputDir);
  if (!outputDirectory.existsSync()) {
    print('❌ Error: Output directory "${outputDirectory.absolute.path}" does not exist.');
    print('👉 Please run "flutter build web" first.');
    exit(1);
  }

  // 2. Bind temporary HTTP server
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8099);
  _serveBuildFolder(server, outputDirectory);
  print('🌐 Served temporary server on http://localhost:8099');

  // 3. Start Puppeteer
  print('🤖 Launching headless browser...');
  final browser = await puppeteer.launch();

  for (final route in routes) {
    final normalizedRoute = route.startsWith('/') ? route : '/$route';
    print('📄 Pre-rendering route: $normalizedRoute');

    final page = await browser.newPage();
    final url = 'http://localhost:8099$normalizedRoute';

    try {
      await page.goto(url, wait: Until.networkAlmostIdle);

      // Wait until Flutter app signals SEO is ready, or timeout
      int elapsed = 0;
      const interval = 100;
      bool isReady = false;

      while (elapsed < renderDelayMs) {
        final readyAttr = await page.evaluate(
          "() => document.documentElement.getAttribute('data-seo-ready')"
        );
        if (readyAttr == 'true') {
          isReady = true;
          break;
        }
        await Future.delayed(const Duration(milliseconds: interval));
        elapsed += interval;
      }

      if (isReady) {
        print('   ✅ Page reported SEO ready state.');
      } else {
        print('   ⚠️ Timeout waiting for SEO ready signal, grabbing DOM snapshot anyway.');
      }

      // Grab rendered DOM HTML
      final html = await page.content;

      // Determine output file location
      // Root '/' goes to 'build/web/index.html'
      // '/about' goes to 'build/web/about/index.html'
      final relativePath = normalizedRoute == '/' ? 'index.html' : '${normalizedRoute.substring(1)}/index.html';
      final file = File('$outputDir/$relativePath');

      // Create target directories if they don't exist
      await file.parent.create(recursive: true);
      await file.writeAsString(html!);
      print('   💾 Saved pre-rendered HTML to: ${file.path}');
    } catch (e) {
      print('   ❌ Error pre-rendering route $normalizedRoute: $e');
    } finally {
      await page.close();
    }
  }

  // 4. Generate sitemap.xml
  if (siteUrl != null && siteUrl.isNotEmpty) {
    print('🗺️ Generating sitemap.xml for site: $siteUrl');
    final sitemapFile = File('$outputDir/sitemap.xml');
    final cleanSiteUrl = siteUrl.endsWith('/') ? siteUrl.substring(0, siteUrl.length - 1) : siteUrl;
    final now = DateTime.now().toIso8601String().substring(0, 10);

    final sitemapBuffer = StringBuffer();
    sitemapBuffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    sitemapBuffer.writeln('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">');

    for (final route in routes) {
      final normalizedRoute = route.startsWith('/') ? route : '/$route';
      final fullUrl = '$cleanSiteUrl$normalizedRoute';
      sitemapBuffer.writeln('  <url>');
      sitemapBuffer.writeln('    <loc>$fullUrl</loc>');
      sitemapBuffer.writeln('    <lastmod>$now</lastmod>');
      sitemapBuffer.writeln('    <changefreq>monthly</changefreq>');
      sitemapBuffer.writeln('    <priority>${normalizedRoute == '/' ? '1.0' : '0.8'}</priority>');
      sitemapBuffer.writeln('  </url>');
    }

    sitemapBuffer.writeln('</urlset>');
    await sitemapFile.writeAsString(sitemapBuffer.toString());
    print('   💾 Sitemap saved to: ${sitemapFile.path}');

    // 5. Generate robots.txt
    print('🤖 Generating robots.txt...');
    final robotsFile = File('$outputDir/robots.txt');
    final robotsContent = '''
User-agent: *
Allow: /

Sitemap: $cleanSiteUrl/sitemap.xml
''';
    await robotsFile.writeAsString(robotsContent);
    print('   💾 Robots.txt saved to: ${robotsFile.path}');
  }

  // Clean up
  print('🛑 Cleaning up server and browser resources...');
  await browser.close();
  await server.close();
  print('🎉 All tasks done! Pre-rendering pipeline complete.');
  exit(0);
}

void _serveBuildFolder(HttpServer server, Directory dir) {
  server.listen((HttpRequest request) async {
    // Determine path
    var path = request.uri.path;
    if (path == '/') {
      path = '/index.html';
    }

    var file = File('${dir.path}$path');

    // If file doesn't exist, we fallback to the main index.html for SPA routing support
    if (!file.existsSync()) {
      file = File('${dir.path}/index.html');
    }

    if (file.existsSync()) {
      request.response.headers.contentType = _getContentType(file.path);
      await file.openRead().pipe(request.response);
    } else {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    }
  });
}

ContentType _getContentType(String filePath) {
  if (filePath.endsWith('.html')) return ContentType.html;
  if (filePath.endsWith('.js')) return ContentType('application', 'javascript');
  if (filePath.endsWith('.css')) return ContentType('text', 'css');
  if (filePath.endsWith('.wasm')) return ContentType('application', 'wasm');
  if (filePath.endsWith('.json')) return ContentType.json;
  if (filePath.endsWith('.xml')) return ContentType('application', 'xml', charset: 'utf-8');
  if (filePath.endsWith('.txt')) return ContentType.text;
  return ContentType.binary;
}
