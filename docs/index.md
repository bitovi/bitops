---
hide:
 - toc
 - navigation
---

<script async defer src="https://buttons.github.io/buttons.js"></script>

<!-- Custom hero banner using docs/stylesheets/custom.css -->
<div class="bitovi-row">
    <div class="bitovi-column bitovi-list">
        <img alt="BitOps Logo" float="middle" style="vertical-align: middle;" src="assets/images/logo/bitops_horizontal.png" width="300" height="75" />
        <ul>
            <li>Keeps the working environment clean</li>
            <li><a href="/operations-repo-structure/" target="_blank">Organizes your deployment configuration</a></li>
            <li>Faster developer onboarding</li>
            <li><a href="https://github.com/bitops-plugins" target="_blank">Integrates with your favorite tools</a></li>
            <li><a href="https://github.com/bitovi/bitops/tree/main/docs/examples" target="_blank">Saves weeks of engineering efforts</a></li>
            <li>Encourages GitOps best practices</li>
            <li><a href="https://github.com/bitovi/bitops" target="_blank">Open source and free</a></li>
        </ul>
    </div>
    <div class="bitovi-column">
        <iframe width="500" height="310" src="https://www.youtube.com/embed/BiytYu3EefY" title="Intro to BitOps" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
    </div>
</div>

<div class="bitovi-row">
    <div class="bitovi-column">
        <h1>BitOps centralizes, organizes, and deploys your Infrastructure-as-Code</h1>
        <div>
        <a class="md-button md-button--primary" href="getting-started">Show me how</a>
        <!--<a class="md-button md-button--primary" href="https://youtu.be/BiytYu3EefY">Show me a video</a>-->
        </div>
        <p>
            <a href="license/"><img alt="LICENSE" src="https://img.shields.io/badge/license-MIT-green"></a>
            <img alt="Python 3.8" src="https://img.shields.io/badge/python-3.8-blue">
            <a href="https://github.com/bitovi/bitops/releases"><img alt="Latest Release" src="https://img.shields.io/github/v/release/bitovi/bitops"></a>
            <a href="https://github.com/bitovi/bitops/discussions"><img alt="BitOps Discussions" src="https://img.shields.io/github/discussions/bitovi/bitops"></a>
            <a href="https://hub.docker.com/r/bitovi/bitops"><img alt="Docker Hub downloads" src="https://img.shields.io/docker/pulls/bitovi/bitops"></a>
            <a href="https://discord.gg/J7ejFsZnJ4"><img alt="Join our Discord" src="https://img.shields.io/badge/discord-join%20chat-611f69.svg?logo=discord"></a>
            <a href="https://github.com/bitovi/bitops"><img alt="Star on Github" src="https://img.shields.io/github/stars/bitovi/bitops?style=plastic"></a>
        </p>
    </div>
</div>
---------------------

BitOps is an automated [orchestrator](getting-started.md) for deployment tools using [GitOps](https://about.gitlab.com/topics/gitops/). 

It leverages a way to describe the infrastructure for many environments and IaC tools called an [Operations Repository](operations-repo-structure.md).

---------------------



<div class="bitovi-row">
<h2>Features</h2>
</div>
<div class="bitovi-row">
    <div class="bitovi-column">
        <h3><a href="configuration-base">Configurable</a></h3>
        <p>Tell BitOps what deployment tools and parameters it needs to deploy your application through environment variables or yaml-based configuration.</p>
    </div>
   <div class="bitovi-column">
        <h3><a href="lifecycle">Event Hooks</a></h3>
        <p>If BitOps doesn't have built-in support for your use case, BitOps can execute arbitrary bash scripts at different points in its lifecycle.</p>
    </div>
    <div class="bitovi-column">
        <h3><a href="plugins">Customizable</a></h3>
        <p>Our newest feature Plugins offer a layer of plug-and-play specialization with the BitOps core. Use one of our officially supported plugins or make your own!</p>
    </div>
    <div class="bitovi-column">
        <h3><a href="examples">Runs Anywhere</a></h3>
        <p>By bundling all logic in BitOps, you can have the same experience regardless of which pipeline service runs your CI. You can even run BitOps locally!</p>
    </div>
</div>
