# Citron CI/CD Workflow Guide

This document provides comprehensive documentation for the Citron CI/CD workflows and best practices.

## Overview

The Citron project uses GitHub Actions for automated building, testing, and deployment across multiple platforms. The workflows are designed to be:

- **Modular**: Reusable workflows for common tasks
- **Efficient**: Optimized caching and parallelization
- **Secure**: Security scanning and vulnerability detection
- **Reliable**: Comprehensive error handling and monitoring
- **Maintainable**: Automated documentation and maintenance

## Workflow Structure

### Core Workflows

#### 1. Build Workflows

- **`build-all.yml`**: Builds for all platforms (Linux, macOS, Windows, Android)
- **`build-stable.yml`**: Builds stable releases from tags
- **Platform-specific workflows**:
  - `build-linux.yml`: Linux builds (x86_64, x86_64_v3, aarch64)
  - `build-macos.yml`: macOS builds with universal binaries
  - `build-windows.yml`: Windows ARM64 builds
  - `build-android.yml`: Android APK builds

#### 2. Reusable Workflows

- **`reusable-version-management.yml`**: Unified version tracking
- **`reusable-version-check.yml`**: Version comparison and build decisions
- **`reusable-caching.yml`**: Comprehensive caching strategy
- **`reusable-monitoring.yml`**: Error handling and performance monitoring
- **`reusable-security.yml`**: Security scanning and vulnerability detection
- **`reusable-testing.yml`**: Cross-platform testing and smoke tests
- **`reusable-maintenance.yml`**: Automated maintenance and documentation

#### 3. Utility Workflows

- **`lint.yml`**: Workflow syntax and best practice validation

## Version Management

### Unified Version System

The project uses a unified version management system with:

- **`LATEST_VERSIONS`**: Single file tracking all platform versions
- **Format**: `platform:hash`
- **Platforms**: linux, linux-v3, linux-arm64, macos, windows-arm64, android, android-8elite

### Version Check Logic

1. **New Commit Detection**: Compare current hash with last built hash
2. **Release Existence**: Check if release exists for the version
3. **Build Decision**: Build if new commit or missing release
4. **Force Build**: Option to force build regardless of changes

## Caching Strategy

### Cache Types

1. **Source Code Cache**: Git objects and references
2. **Dependency Cache**: Package managers (npm, pip, cargo, etc.)
3. **Build Cache**: Compiled artifacts and object files
4. **Platform-Specific Caches**:
   - vcpkg dependencies
   - Android SDK/NDK
   - Homebrew packages (macOS)
   - Docker layers

### Cache Keys

- **Base Key**: `os-platform-cache_type-additional_keys`
- **Fallback Keys**: Progressive fallback for cache misses
- **Versioning**: Hash-based cache invalidation

## Security Features

### SAST (Static Application Security Testing)

- **CodeQL**: GitHub's semantic code analysis
- **Semgrep**: Custom security rules and patterns
- **OWASP Rules**: OWASP Top 10 compliance

### Dependency Scanning

- **Node.js**: npm audit for vulnerability detection
- **Python**: Safety for known vulnerabilities
- **Rust**: cargo-audit for crate vulnerabilities
- **Java**: OWASP Dependency Check
- **Container**: Trivy for Docker image scanning

### Secrets Detection

- **Git Secrets**: Prevent secrets in git history
- **TruffleHog**: Scan for exposed credentials
- **License Compliance**: License scanning and compliance

## Testing Strategy

### Test Types

1. **Smoke Tests**: Basic functionality verification
   - Binary existence and execution
   - Help command functionality
   - Version output validation

2. **Integration Tests**: System integration verification
   - Configuration system
   - Logging system
   - Plugin system

3. **Performance Tests**: Performance benchmarking
   - Memory usage measurement
   - Startup time testing
   - CPU usage monitoring

4. **Compatibility Tests**: Platform compatibility
   - Library dependencies
   - Graphics API support (OpenGL/Vulkan/Metal)

### Test Execution

- **Parallel Execution**: Tests run in parallel where possible
- **Platform-Specific**: Different tests for different platforms
- **Artifact Upload**: Test results and logs preserved
- **Failure Handling**: Detailed error reporting and recovery

## Monitoring and Error Handling

### Build Monitoring

- **Performance Metrics**: Build duration and resource usage
- **Error Analysis**: Automatic error categorization and suggestions
- **Notifications**: Discord integration for critical failures
- **Health Checks**: Build health scoring and reporting

### Error Recovery

- **Automatic Retries**: Network and transient failure recovery
- **Graceful Degradation**: Continue on non-critical failures
- **Detailed Logging**: Comprehensive error information
- **Issue Creation**: Automatic issue creation for persistent problems

## Performance Optimization

### Build Optimization

- **Parallel Jobs**: Maximize concurrent execution
- **Resource Management**: Optimize memory and CPU usage
- **Incremental Builds**: Build only changed components
- **Artifact Deduplication**: Avoid redundant artifact uploads

### Caching Optimization

- **Multi-Level Caching**: Source, dependencies, and build artifacts
- **Smart Invalidation**: Hash-based cache invalidation
- **Cross-Platform Sharing**: Share caches where possible
- **Compression**: Compress large cache files

## Maintenance Automation

### Automated Tasks

1. **Documentation Updates**:
   - Changelog generation
   - README updates
   - API documentation

2. **Dependency Management**:
   - Security audits
   - Version updates
   - Vulnerability scanning

3. **Code Quality**:
   - Linting and formatting
   - Code analysis
   - Best practice enforcement

4. **Workflow Optimization**:
   - Action version updates
   - Performance monitoring
   - Cleanup and optimization

### Scheduled Maintenance

- **Daily**: Dependency audits and security scans
- **Weekly**: Documentation updates and cleanup
- **Monthly**: Workflow optimization and performance review

## Best Practices

### Workflow Design

1. **Modularity**: Use reusable workflows for common tasks
2. **Separation of Concerns**: Separate build, test, and deploy logic
3. **Error Handling**: Implement comprehensive error handling
4. **Security**: Always scan for vulnerabilities and secrets
5. **Performance**: Optimize for speed and resource usage

### Version Management

1. **Consistency**: Use unified version tracking across platforms
2. **Automation**: Automate version updates and releases
3. **Traceability**: Maintain clear version history and changelogs
4. **Rollback**: Support easy rollback to previous versions

### Testing

1. **Comprehensive Coverage**: Test all critical functionality
2. **Platform Coverage**: Test across all supported platforms
3. **Performance Monitoring**: Track performance metrics over time
4. **Failure Analysis**: Analyze and learn from test failures

### Security

1. **Defense in Depth**: Multiple layers of security scanning
2. **Regular Updates**: Keep dependencies and tools updated
3. **Secrets Management**: Never commit secrets to repository
4. **Access Control**: Limit access to sensitive workflows

## Troubleshooting

### Common Issues

1. **Build Failures**:
   - Check error logs and diagnostics
   - Verify dependencies and environment
   - Review recent changes for breaking modifications

2. **Performance Issues**:
   - Analyze build metrics and timings
   - Check cache hit rates
   - Review resource usage

3. **Security Issues**:
   - Review vulnerability reports
   - Update affected dependencies
   - Implement security patches

4. **Testing Issues**:
   - Check test environment setup
   - Verify test data and configurations
   - Review test logs for errors

### Debugging Tools

- **GitHub Actions Logs**: Detailed step-by-step logs
- **Artifact Downloads**: Access to build outputs and logs
- **Performance Metrics**: Build duration and resource usage
- **Security Reports**: Vulnerability and compliance reports

## Contributing

### Adding New Workflows

1. **Follow Patterns**: Use existing workflows as templates
2. **Reusability**: Create reusable workflows when possible
3. **Documentation**: Document new workflows and changes
4. **Testing**: Test workflows thoroughly before merging

### Improving Workflows

1. **Performance**: Look for optimization opportunities
2. **Reliability**: Improve error handling and recovery
3. **Security**: Add security scanning and validation
4. **Maintainability**: Keep workflows clean and well-documented

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax Reference](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Reusable Workflows Guide](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Security Scanning Guide](https://docs.github.com/en/code-security/code-scanning)

## Support

For questions, issues, or improvements:

1. **Check Documentation**: Review this guide and GitHub documentation
2. **Search Issues**: Check existing issues and discussions
3. **Create Issue**: Report new issues with detailed information
4. **Contribute**: Submit pull requests for improvements

---

**Last Updated**: $(date)
**Version**: 1.0.0
**Maintainer**: Citron CI/CD Team