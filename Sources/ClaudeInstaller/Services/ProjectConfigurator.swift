import Foundation

final class ProjectConfigurator: Sendable {

    func generateGitignore(at projectPath: String) async throws {
        let gitignorePath = "\(FileSystemHelper.expandPath(projectPath))/.gitignore"

        // Don't overwrite existing .gitignore
        if FileSystemHelper.exists(gitignorePath) {
            return
        }

        let content = """
        # Dependencies
        node_modules/
        .pnp.*
        .yarn/install-state.gz

        # Build outputs
        dist/
        build/
        .next/
        out/
        .nuxt/
        .output/

        # Environment variables
        .env
        .env.local
        .env.*.local

        # IDE and editors
        .vscode/settings.json
        .idea/
        *.swp
        *.swo
        *~
        .DS_Store

        # Testing
        coverage/
        .nyc_output/

        # Logs
        *.log
        npm-debug.log*
        yarn-debug.log*
        yarn-error.log*

        # OS files
        .DS_Store
        Thumbs.db
        """

        try FileSystemHelper.createDirectory(projectPath)
        try FileSystemHelper.writeFile(gitignorePath, content: content)
    }

    func generateClaudeignore(at projectPath: String) async throws {
        let claudeignorePath = "\(FileSystemHelper.expandPath(projectPath))/.claudeignore"

        // Don't overwrite existing
        if FileSystemHelper.exists(claudeignorePath) {
            return
        }

        let content = """
        # Large directories that Claude should not index
        node_modules/
        .next/
        dist/
        build/
        out/
        .nuxt/
        .output/
        .git/
        .svn/

        # Lock files
        package-lock.json
        yarn.lock
        pnpm-lock.yaml
        Podfile.lock

        # Binary and generated files
        *.min.js
        *.min.css
        *.map
        *.wasm
        *.pyc
        *.pyo
        __pycache__/

        # Data files
        *.sqlite
        *.db
        *.csv
        *.parquet

        # Media files
        *.png
        *.jpg
        *.jpeg
        *.gif
        *.ico
        *.svg
        *.mp4
        *.webm
        *.mp3
        *.woff
        *.woff2
        *.ttf
        *.eot
        """

        try FileSystemHelper.createDirectory(projectPath)
        try FileSystemHelper.writeFile(claudeignorePath, content: content)
    }
}
