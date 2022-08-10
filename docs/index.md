---
hide:
 - toc
 - navigation
---

<script async defer src="https://buttons.github.io/buttons.js"></script>

<!-- Custom hero banner using docs/stylesheets/custom.css -->
<div class="bitovi-row">
    <div class="bitovi-column">
        <img alt="Logo" float="middle" style="vertical-align: middle;" src="assets/images/logo/Bitops%28RGB%29_L2_Full_4C.png" width="350" />
    </div>
</div>

<div class="bitovi-row">
    <div class="bitovi-column">
        <h1>BitOps packages, centralizes and organizes your Infrastructure-as-Code</h1>
        <a class="md-button md-button--primary" href="getting-started">Show me how</a>
        <p>
            <a href="https://github.com/bitovi/bitops/releases"><img alt="Latest Release" src="https://img.shields.io/github/v/release/bitovi/bitops"></a>
            <a href="https://www.bitovi.com/community/slack?utm_source=badge&amp;utm_medium=badge&amp;utm_campaign=pr-badge&amp;utm_content=badge"><img alt="Join our Slack" src="https://img.shields.io/badge/slack-join%20chat-611f69.svg"></a>
            <a href="license/"><img alt="LICENSE" src="https://img.shields.io/badge/license-MIT-green"></a>
            <a class="github-button" href="https://github.com/bitovi/bitops" data-icon="octicon-star" data-show-count="true" aria-label="Star BitOps on GitHub">Star</a>
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
