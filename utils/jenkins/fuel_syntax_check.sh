


<!DOCTYPE html>
<html>
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# githubog: http://ogp.me/ns/fb/githubog#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <title>fuel/utils/jenkins/fuel_syntax_check.sh at master · Mirantis/fuel · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub" />
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub" />
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png" />
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png" />
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png" />
    <link rel="logo" type="image/svg" href="https://github-media-downloads.s3.amazonaws.com/github-logo.svg" />
    <meta property="og:image" content="https://github.global.ssl.fastly.net/images/modules/logos_page/Octocat.png">
    <meta name="hostname" content="github-fe113-cp1-prd.iad.github.net">
    <meta name="ruby" content="ruby 1.9.3p194-tcs-github-tcmalloc (2012-05-25, TCS patched 2012-05-27, GitHub v1.0.32) [x86_64-linux]">
    <link rel="assets" href="https://github.global.ssl.fastly.net/">
    <link rel="xhr-socket" href="/_sockets" />
    
    


    <meta name="msapplication-TileImage" content="/windows-tile.png" />
    <meta name="msapplication-TileColor" content="#ffffff" />
    <meta name="selected-link" value="repo_source" data-pjax-transient />
    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="github" name="octolytics-app-id" /><meta content="cad924c8-2b9e-431c-b3a9-7211bb069a91" name="octolytics-dimension-request_id" />
    

    
    
    <link rel="icon" type="image/x-icon" href="/favicon.ico" />

    <meta content="authenticity_token" name="csrf-param" />
<meta content="rcxZHeoj419JialaTRcKEgqyMMjdBUYASIIYIyMKA5s=" name="csrf-token" />

    <link href="https://github.global.ssl.fastly.net/assets/github-9c689a491bb7527f0a3f3d1a5d68322d7e726632.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://github.global.ssl.fastly.net/assets/github2-439e136a912bf821473757ddeaa407651188d94c.css" media="all" rel="stylesheet" type="text/css" />
    


      <script src="https://github.global.ssl.fastly.net/assets/frameworks-f86a2975a82dceee28e5afe598d1ebbfd7109d79.js" type="text/javascript"></script>
      <script src="https://github.global.ssl.fastly.net/assets/github-8b598e4eeb36a68a0d1011fb20bdb1ec3a91fd1b.js" type="text/javascript"></script>
      
      <meta http-equiv="x-pjax-version" content="28f15ca64794a296476e5f47fb13a859">

        <link data-pjax-transient rel='permalink' href='/Mirantis/fuel/blob/4297a97bfdd228182c6dcd59672347adbbb9ab4c/utils/jenkins/fuel_syntax_check.sh'>
  <meta property="og:title" content="fuel"/>
  <meta property="og:type" content="githubog:gitrepository"/>
  <meta property="og:url" content="https://github.com/Mirantis/fuel"/>
  <meta property="og:image" content="https://github.global.ssl.fastly.net/images/gravatars/gravatar-user-420.png"/>
  <meta property="og:site_name" content="GitHub"/>
  <meta property="og:description" content="Contribute to fuel development by creating an account on GitHub."/>

  <meta name="description" content="Contribute to fuel development by creating an account on GitHub." />

  <meta content="609319" name="octolytics-dimension-user_id" /><meta content="Mirantis" name="octolytics-dimension-user_login" /><meta content="8776953" name="octolytics-dimension-repository_id" /><meta content="Mirantis/fuel" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="8776953" name="octolytics-dimension-repository_network_root_id" /><meta content="Mirantis/fuel" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/Mirantis/fuel/commits/master.atom" rel="alternate" title="Recent Commits to fuel:master" type="application/atom+xml" />

  </head>


  <body class="logged_out page-blob  vis-public env-production ">

    <div class="wrapper">
      
      
      


      
      <div class="header header-logged-out">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions">
        <a class="button primary" href="/signup">Sign up</a>
      <a class="button" href="/login?return_to=%2FMirantis%2Ffuel%2Fblob%2Fmaster%2Futils%2Fjenkins%2Ffuel_syntax_check.sh">Sign in</a>
    </div>

    <div class="command-bar js-command-bar  in-repository">

      <ul class="top-nav">
          <li class="explore"><a href="/explore">Explore</a></li>
        <li class="features"><a href="/features">Features</a></li>
          <li class="enterprise"><a href="https://enterprise.github.com/">Enterprise</a></li>
          <li class="blog"><a href="/blog">Blog</a></li>
      </ul>
        <form accept-charset="UTF-8" action="/search" class="command-bar-form" id="top_search_form" method="get">

<input type="text" data-hotkey="/ s" name="q" id="js-command-bar-field" placeholder="Search or type a command" tabindex="1" autocapitalize="off"
    
    
      data-repo="Mirantis/fuel"
      data-branch="master"
      data-sha="b081cb67139b88c1a45897f9959286fb027e22bd"
  >

    <input type="hidden" name="nwo" value="Mirantis/fuel" />

    <div class="select-menu js-menu-container js-select-menu search-context-select-menu">
      <span class="minibutton select-menu-button js-menu-target">
        <span class="js-select-button">This repository</span>
      </span>

      <div class="select-menu-modal-holder js-menu-content js-navigation-container">
        <div class="select-menu-modal">

          <div class="select-menu-item js-navigation-item js-this-repository-navigation-item selected">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" class="js-search-this-repository" name="search_target" value="repository" checked="checked" />
            <div class="select-menu-item-text js-select-button-text">This repository</div>
          </div> <!-- /.select-menu-item -->

          <div class="select-menu-item js-navigation-item js-all-repositories-navigation-item">
            <span class="select-menu-item-icon octicon octicon-check"></span>
            <input type="radio" name="search_target" value="global" />
            <div class="select-menu-item-text js-select-button-text">All repositories</div>
          </div> <!-- /.select-menu-item -->

        </div>
      </div>
    </div>

  <span class="octicon help tooltipped downwards" title="Show command bar help">
    <span class="octicon octicon-question"></span>
  </span>


  <input type="hidden" name="ref" value="cmdform">

</form>
    </div>

  </div>
</div>


      


          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        

<ul class="pagehead-actions">


  <li>
  <a href="/login?return_to=%2FMirantis%2Ffuel"
  class="minibutton with-count js-toggler-target star-button entice tooltipped upwards"
  title="You must be signed in to use this feature" rel="nofollow">
  <span class="octicon octicon-star"></span>Star
</a>
<a class="social-count js-social-count" href="/Mirantis/fuel/stargazers">
  10
</a>

  </li>

    <li>
      <a href="/login?return_to=%2FMirantis%2Ffuel"
        class="minibutton with-count js-toggler-target fork-button entice tooltipped upwards"
        title="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-git-branch"></span>Fork
      </a>
      <a href="/Mirantis/fuel/network" class="social-count">
        37
      </a>
    </li>
</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="repo-label"><span>public</span></span>
          <span class="mega-octicon octicon-repo"></span>
          <span class="author">
            <a href="/Mirantis" class="url fn" itemprop="url" rel="author"><span itemprop="title">Mirantis</span></a></span
          ><span class="repohead-name-divider">/</span><strong
          ><a href="/Mirantis/fuel" class="js-current-repository js-repo-home-link">fuel</a></strong>

          <span class="page-context-loader">
            <img alt="Octocat-spinner-32" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">

      <div class="repository-with-sidebar repo-container ">

        <div class="repository-sidebar">
            

<div class="repo-nav repo-nav-full js-repository-container-pjax js-octicon-loaders">
  <div class="repo-nav-contents">
    <ul class="repo-menu">
      <li class="tooltipped leftwards" title="Code">
        <a href="/Mirantis/fuel" aria-label="Code" class="js-selected-navigation-item selected" data-gotokey="c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_tags repo_branches /Mirantis/fuel">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped leftwards" title="Issues">
          <a href="/Mirantis/fuel/issues" aria-label="Issues" class="js-selected-navigation-item js-disable-pjax" data-gotokey="i" data-selected-links="repo_issues /Mirantis/fuel/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class='counter'>18</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped leftwards" title="Pull Requests"><a href="/Mirantis/fuel/pulls" aria-label="Pull Requests" class="js-selected-navigation-item js-disable-pjax" data-gotokey="p" data-selected-links="repo_pulls /Mirantis/fuel/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class='counter'>18</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


        <li class="tooltipped leftwards" title="Wiki">
          <a href="/Mirantis/fuel/wiki" aria-label="Wiki" class="js-selected-navigation-item " data-pjax="true" data-selected-links="repo_wiki /Mirantis/fuel/wiki">
            <span class="octicon octicon-book"></span> <span class="full-word">Wiki</span>
            <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>
    </ul>
    <div class="repo-menu-separator"></div>
    <ul class="repo-menu">

      <li class="tooltipped leftwards" title="Pulse">
        <a href="/Mirantis/fuel/pulse" aria-label="Pulse" class="js-selected-navigation-item " data-pjax="true" data-selected-links="pulse /Mirantis/fuel/pulse">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Graphs">
        <a href="/Mirantis/fuel/graphs" aria-label="Graphs" class="js-selected-navigation-item " data-pjax="true" data-selected-links="repo_graphs repo_contributors /Mirantis/fuel/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped leftwards" title="Network">
        <a href="/Mirantis/fuel/network" aria-label="Network" class="js-selected-navigation-item js-disable-pjax" data-selected-links="repo_network /Mirantis/fuel/network">
          <span class="octicon octicon-git-branch"></span> <span class="full-word">Network</span>
          <img alt="Octocat-spinner-32" class="mini-loader" height="16" src="https://github.global.ssl.fastly.net/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

            <div class="only-with-full-nav">
              

  

<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><strong>HTTPS</strong> clone URL</h3>

  <input type="text" class="clone js-url-field"
         value="https://github.com/Mirantis/fuel.git" readonly="readonly">

  <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/Mirantis/fuel.git" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
</div>

  

<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><strong>Subversion</strong> checkout URL</h3>

  <input type="text" class="clone js-url-field"
         value="https://github.com/Mirantis/fuel" readonly="readonly">

  <span class="js-zeroclipboard url-box-clippy minibutton zeroclipboard-button" data-clipboard-text="https://github.com/Mirantis/fuel" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
</div>



<p class="clone-options">You can clone with
    <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>,
    <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>,
  and <a href="https://help.github.com/articles/which-remote-url-should-i-use">other methods.</a>
</p>



                <a href="/Mirantis/fuel/archive/master.zip"
                   class="minibutton sidebar-button"
                   title="Download this repository as a zip file"
                   rel="nofollow">
                  <span class="octicon octicon-cloud-download"></span>
                  Download ZIP
                </a>
            </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          


<!-- blob contrib key: blob_contributors:v21:d470e41214d17110a1b0710d841703b0 -->
<!-- blob contrib frag key: views10/v8/blob_contributors:v21:d470e41214d17110a1b0710d841703b0 -->

<p title="This is a placeholder element" class="js-history-link-replace hidden"></p>

<a href="/Mirantis/fuel/find/master" data-pjax data-hotkey="t" style="display:none">Show File Finder</a>

<div class="file-navigation">
  


<div class="select-menu js-menu-container js-select-menu" >
  <span class="minibutton select-menu-button js-menu-target" data-hotkey="w"
    data-master-branch="master"
    data-ref="master" role="button" aria-label="Switch branches or tags">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax>

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-remove-close js-menu-close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/buildscripts/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="buildscripts" data-skip-pjax="true" rel="nofollow" title="buildscripts">buildscripts</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/develop/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="develop" data-skip-pjax="true" rel="nofollow" title="develop">develop</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/develop-rhosdev/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="develop-rhosdev" data-skip-pjax="true" rel="nofollow" title="develop-rhosdev">develop-rhosdev</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/essex/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="essex" data-skip-pjax="true" rel="nofollow" title="essex">essex</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-2.1.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-2.1.1" data-skip-pjax="true" rel="nofollow" title="fuel-2.1.1">fuel-2.1.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-2.1-rhosdev/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-2.1-rhosdev" data-skip-pjax="true" rel="nofollow" title="fuel-2.1-rhosdev">fuel-2.1-rhosdev</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-2.2/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-2.2" data-skip-pjax="true" rel="nofollow" title="fuel-2.2">fuel-2.2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-3.0.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-3.0.1" data-skip-pjax="true" rel="nofollow" title="fuel-3.0.1">fuel-3.0.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-3.0.1-rhosdev/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-3.0.1-rhosdev" data-skip-pjax="true" rel="nofollow" title="fuel-3.0.1-rhosdev">fuel-3.0.1-rhosdev</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-3.0-rhosdev/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-3.0-rhosdev" data-skip-pjax="true" rel="nofollow" title="fuel-3.0-rhosdev">fuel-3.0-rhosdev</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-3.1.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-3.1.1" data-skip-pjax="true" rel="nofollow" title="fuel-3.1.1">fuel-3.1.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-666/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-666" data-skip-pjax="true" rel="nofollow" title="fuel-666">fuel-666</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel-777-vvk/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-777-vvk" data-skip-pjax="true" rel="nofollow" title="fuel-777-vvk">fuel-777-vvk</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuel_web/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel_web" data-skip-pjax="true" rel="nofollow" title="fuel_web">fuel_web</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/fuelweb-3.0.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuelweb-3.0.1" data-skip-pjax="true" rel="nofollow" title="fuelweb-3.0.1">fuelweb-3.0.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/grizzly/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="grizzly" data-skip-pjax="true" rel="nofollow" title="grizzly">grizzly</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/master/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="master" data-skip-pjax="true" rel="nofollow" title="master">master</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/oleg-fuel-3.0-rhosdev/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="oleg-fuel-3.0-rhosdev" data-skip-pjax="true" rel="nofollow" title="oleg-fuel-3.0-rhosdev">oleg-fuel-3.0-rhosdev</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/prd1302/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="prd1302" data-skip-pjax="true" rel="nofollow" title="prd1302">prd1302</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/prd1499/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="prd1499" data-skip-pjax="true" rel="nofollow" title="prd1499">prd1499</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/puppet-corosync-nokogiri/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="puppet-corosync-nokogiri" data-skip-pjax="true" rel="nofollow" title="puppet-corosync-nokogiri">puppet-corosync-nokogiri</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/puppetdb/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="puppetdb" data-skip-pjax="true" rel="nofollow" title="puppetdb">puppetdb</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/refactor_vars/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="refactor_vars" data-skip-pjax="true" rel="nofollow" title="refactor_vars">refactor_vars</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/ubuntu-3.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="ubuntu-3.1" data-skip-pjax="true" rel="nofollow" title="ubuntu-3.1">ubuntu-3.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/blob/ubuntu-3.2-WIP/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="ubuntu-3.2-WIP" data-skip-pjax="true" rel="nofollow" title="ubuntu-3.2-WIP">ubuntu-3.2-WIP</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/v.0.1.0-essex-1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="v.0.1.0-essex-1" data-skip-pjax="true" rel="nofollow" title="v.0.1.0-essex-1">v.0.1.0-essex-1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/fuel-3.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="fuel-3.1" data-skip-pjax="true" rel="nofollow" title="fuel-3.1">fuel-3.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/folsom-stable-ubuntu-minimal/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="folsom-stable-ubuntu-minimal" data-skip-pjax="true" rel="nofollow" title="folsom-stable-ubuntu-minimal">folsom-stable-ubuntu-minimal</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/20121219-stable-CentOS/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="20121219-stable-CentOS" data-skip-pjax="true" rel="nofollow" title="20121219-stable-CentOS">20121219-stable-CentOS</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/20121217-stable-CentOS-simple/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="20121217-stable-CentOS-simple" data-skip-pjax="true" rel="nofollow" title="20121217-stable-CentOS-simple">20121217-stable-CentOS-simple</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/3.0-grizzly-CentOS_6.4-rc/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="3.0-grizzly-CentOS_6.4-rc" data-skip-pjax="true" rel="nofollow" title="3.0-grizzly-CentOS_6.4-rc">3.0-grizzly-CentOS_6.4-rc</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/3.0-grizzly-CentOS6.4-rc/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="3.0-grizzly-CentOS6.4-rc" data-skip-pjax="true" rel="nofollow" title="3.0-grizzly-CentOS6.4-rc">3.0-grizzly-CentOS6.4-rc</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/3.0-grizzly/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="3.0-grizzly" data-skip-pjax="true" rel="nofollow" title="3.0-grizzly">3.0-grizzly</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/3.0-alpha/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="3.0-alpha" data-skip-pjax="true" rel="nofollow" title="3.0-alpha">3.0-alpha</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/3.0.1-grizzly/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="3.0.1-grizzly" data-skip-pjax="true" rel="nofollow" title="3.0.1-grizzly">3.0.1-grizzly</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.2-folsom/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.2-folsom" data-skip-pjax="true" rel="nofollow" title="2.2-folsom">2.2-folsom</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1-folsom-pre/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1-folsom-pre" data-skip-pjax="true" rel="nofollow" title="2.1-folsom-pre">2.1-folsom-pre</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1-folsom-docs/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1-folsom-docs" data-skip-pjax="true" rel="nofollow" title="2.1-folsom-docs">2.1-folsom-docs</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1-folsom/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1-folsom" data-skip-pjax="true" rel="nofollow" title="2.1-folsom">2.1-folsom</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1.2-folsom/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1.2-folsom" data-skip-pjax="true" rel="nofollow" title="2.1.2-folsom">2.1.2-folsom</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1.1-folsom/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1.1-folsom" data-skip-pjax="true" rel="nofollow" title="2.1.1-folsom">2.1.1-folsom</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1.1" data-skip-pjax="true" rel="nofollow" title="2.1.1">2.1.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.1" data-skip-pjax="true" rel="nofollow" title="2.1">2.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/2.0-folsom/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="2.0-folsom" data-skip-pjax="true" rel="nofollow" title="2.0-folsom">2.0-folsom</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/1.0-essex/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="1.0-essex" data-skip-pjax="true" rel="nofollow" title="1.0-essex">1.0-essex</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/0.2RC1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="0.2RC1" data-skip-pjax="true" rel="nofollow" title="0.2RC1">0.2RC1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/0.1.99.3/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="0.1.99.3" data-skip-pjax="true" rel="nofollow" title="0.1.99.3">0.1.99.3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/0.1.99.2/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="0.1.99.2" data-skip-pjax="true" rel="nofollow" title="0.1.99.2">0.1.99.2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/0.1.99.1/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="0.1.99.1" data-skip-pjax="true" rel="nofollow" title="0.1.99.1">0.1.99.1</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/Mirantis/fuel/tree/0.1.99.0/utils/jenkins/fuel_syntax_check.sh" class="js-navigation-open select-menu-item-text js-select-button-text css-truncate-target" data-name="0.1.99.0" data-skip-pjax="true" rel="nofollow" title="0.1.99.0">0.1.99.0</a>
            </div> <!-- /.select-menu-item -->
        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Mirantis/fuel" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">fuel</span></a></span></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Mirantis/fuel/tree/master/utils" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">utils</span></a></span><span class="separator"> / </span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/Mirantis/fuel/tree/master/utils/jenkins" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">jenkins</span></a></span><span class="separator"> / </span><strong class="final-path">fuel_syntax_check.sh</strong> <span class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="utils/jenkins/fuel_syntax_check.sh" data-copied-hint="copied!" title="copy to clipboard"><span class="octicon octicon-clippy"></span></span>
  </div>
</div>


  
  <div class="commit file-history-tease">
    <img class="main-avatar" height="24" src="https://1.gravatar.com/avatar/c8ccf4c73f78c0548ca4a08104f0bb8b?d=https%3A%2F%2Fidenticons.github.com%2F15ff515496e87e09445ee09fa85dc4cc.png&amp;s=140" width="24" />
    <span class="author"><a href="/Zipfer" rel="author">Zipfer</a></span>
    <time class="js-relative-date" datetime="2013-09-04T14:55:03-07:00" title="2013-09-04 14:55:03">September 04, 2013</time>
    <div class="commit-title">
        <a href="/Mirantis/fuel/commit/676198dd04060930d2bb8880d29ad8b55e712cd8" class="message" data-pjax="true" title="Get rid of set -e, set +e, etc. in syntax check script">Get rid of set -e, set +e, etc. in syntax check script</a>
    </div>

    <div class="participation">
      <p class="quickstat"><a href="#blob_contributors_box" rel="facebox"><strong>1</strong> contributor</a></p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
        <li class="facebox-user-list-item">
          <img height="24" src="https://1.gravatar.com/avatar/c8ccf4c73f78c0548ca4a08104f0bb8b?d=https%3A%2F%2Fidenticons.github.com%2F15ff515496e87e09445ee09fa85dc4cc.png&amp;s=140" width="24" />
          <a href="/Zipfer">Zipfer</a>
        </li>
      </ul>
    </div>
  </div>


<div id="files" class="bubble">
  <div class="file">
    <div class="meta">
      <div class="info">
        <span class="icon"><b class="octicon octicon-file-text"></b></span>
        <span class="mode" title="File Mode">executable file</span>
          <span>80 lines (70 sloc)</span>
        <span>2.093 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
              <a class="minibutton disabled js-entice" href=""
                 data-entice="You must be signed in to make or propose changes">Edit</a>
          <a href="/Mirantis/fuel/raw/master/utils/jenkins/fuel_syntax_check.sh" class="button minibutton " id="raw-url">Raw</a>
            <a href="/Mirantis/fuel/blame/master/utils/jenkins/fuel_syntax_check.sh" class="button minibutton ">Blame</a>
          <a href="/Mirantis/fuel/commits/master/utils/jenkins/fuel_syntax_check.sh" class="button minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->
            <a class="minibutton danger empty-icon js-entice" href=""
               data-entice="You must be signed in and on a branch to make or propose changes">
            Delete
          </a>
      </div><!-- /.actions -->

    </div>
        <div class="blob-wrapper data type-shell js-blob-data">
        <table class="file-code file-diff">
          <tr class="file-code-line">
            <td class="blob-line-nums">
              <span id="L1" rel="#L1">1</span>
<span id="L2" rel="#L2">2</span>
<span id="L3" rel="#L3">3</span>
<span id="L4" rel="#L4">4</span>
<span id="L5" rel="#L5">5</span>
<span id="L6" rel="#L6">6</span>
<span id="L7" rel="#L7">7</span>
<span id="L8" rel="#L8">8</span>
<span id="L9" rel="#L9">9</span>
<span id="L10" rel="#L10">10</span>
<span id="L11" rel="#L11">11</span>
<span id="L12" rel="#L12">12</span>
<span id="L13" rel="#L13">13</span>
<span id="L14" rel="#L14">14</span>
<span id="L15" rel="#L15">15</span>
<span id="L16" rel="#L16">16</span>
<span id="L17" rel="#L17">17</span>
<span id="L18" rel="#L18">18</span>
<span id="L19" rel="#L19">19</span>
<span id="L20" rel="#L20">20</span>
<span id="L21" rel="#L21">21</span>
<span id="L22" rel="#L22">22</span>
<span id="L23" rel="#L23">23</span>
<span id="L24" rel="#L24">24</span>
<span id="L25" rel="#L25">25</span>
<span id="L26" rel="#L26">26</span>
<span id="L27" rel="#L27">27</span>
<span id="L28" rel="#L28">28</span>
<span id="L29" rel="#L29">29</span>
<span id="L30" rel="#L30">30</span>
<span id="L31" rel="#L31">31</span>
<span id="L32" rel="#L32">32</span>
<span id="L33" rel="#L33">33</span>
<span id="L34" rel="#L34">34</span>
<span id="L35" rel="#L35">35</span>
<span id="L36" rel="#L36">36</span>
<span id="L37" rel="#L37">37</span>
<span id="L38" rel="#L38">38</span>
<span id="L39" rel="#L39">39</span>
<span id="L40" rel="#L40">40</span>
<span id="L41" rel="#L41">41</span>
<span id="L42" rel="#L42">42</span>
<span id="L43" rel="#L43">43</span>
<span id="L44" rel="#L44">44</span>
<span id="L45" rel="#L45">45</span>
<span id="L46" rel="#L46">46</span>
<span id="L47" rel="#L47">47</span>
<span id="L48" rel="#L48">48</span>
<span id="L49" rel="#L49">49</span>
<span id="L50" rel="#L50">50</span>
<span id="L51" rel="#L51">51</span>
<span id="L52" rel="#L52">52</span>
<span id="L53" rel="#L53">53</span>
<span id="L54" rel="#L54">54</span>
<span id="L55" rel="#L55">55</span>
<span id="L56" rel="#L56">56</span>
<span id="L57" rel="#L57">57</span>
<span id="L58" rel="#L58">58</span>
<span id="L59" rel="#L59">59</span>
<span id="L60" rel="#L60">60</span>
<span id="L61" rel="#L61">61</span>
<span id="L62" rel="#L62">62</span>
<span id="L63" rel="#L63">63</span>
<span id="L64" rel="#L64">64</span>
<span id="L65" rel="#L65">65</span>
<span id="L66" rel="#L66">66</span>
<span id="L67" rel="#L67">67</span>
<span id="L68" rel="#L68">68</span>
<span id="L69" rel="#L69">69</span>
<span id="L70" rel="#L70">70</span>
<span id="L71" rel="#L71">71</span>
<span id="L72" rel="#L72">72</span>
<span id="L73" rel="#L73">73</span>
<span id="L74" rel="#L74">74</span>
<span id="L75" rel="#L75">75</span>
<span id="L76" rel="#L76">76</span>
<span id="L77" rel="#L77">77</span>
<span id="L78" rel="#L78">78</span>
<span id="L79" rel="#L79">79</span>

            </td>
            <td class="blob-line-code">
                    <div class="highlight"><pre><div class='line' id='LC1'><span class="c">#TODO: Run these in parallel - we have 4 cores.</span></div><div class='line' id='LC2'><span class="c">#TODO: Control the environment (through the config dir?).</span></div><div class='line' id='LC3'><span class="c">#      We want to parse for all environments.</span></div><div class='line' id='LC4'><span class="c">#      Is this being done, contrary to puppet report?</span></div><div class='line' id='LC5'><span class="c">#TODO: Even with --ignoreimport, some may be pulling in others,</span></div><div class='line' id='LC6'><span class="c">#      meaning we&#39;re checking multiple times.</span></div><div class='line' id='LC7'><br/></div><div class='line' id='LC8'><span class="c">#all_files=`find -name &quot;*.pp&quot; -o -name &quot;*.erb&quot; -o -name &quot;*.sh&quot; -o -name &quot;*.rb&quot;`</span></div><div class='line' id='LC9'><br/></div><div class='line' id='LC10'><span class="nv">ruby_files</span><span class="o">=</span><span class="sb">`</span>find -type f -print0 | xargs -0 file -i | grep -i ruby | awk -F: <span class="s1">&#39;{ print $1 }&#39;</span><span class="sb">`</span></div><div class='line' id='LC11'><span class="nv">all_files</span><span class="o">=</span><span class="s2">&quot;${ruby_files} `find -name &quot;</span>*.pp<span class="s2">&quot; -o -name &quot;</span>*.erb<span class="s2">&quot; -o -name &quot;</span>*.sh<span class="s2">&quot;`&quot;</span></div><div class='line' id='LC12'><span class="nv">num_files</span><span class="o">=</span><span class="sb">`</span><span class="nb">echo</span> <span class="nv">$all_files</span> | wc -w<span class="sb">`</span></div><div class='line' id='LC13'><br/></div><div class='line' id='LC14'><span class="k">if </span><span class="nb">test</span> <span class="nv">$num_files</span> -eq <span class="s2">&quot;0&quot;</span> ; <span class="k">then</span></div><div class='line' id='LC15'><span class="k">  </span><span class="nb">echo</span> <span class="s2">&quot;WARNING: no .sh, .pp, .rb or .erb files found&quot;</span></div><div class='line' id='LC16'>&nbsp;&nbsp;<span class="nb">exit </span>0</div><div class='line' id='LC17'><span class="k">fi</span></div><div class='line' id='LC18'><br/></div><div class='line' id='LC19'><span class="nb">echo</span> <span class="s2">&quot;Checking $num_files files for syntax errors.&quot;</span></div><div class='line' id='LC20'><span class="nb">echo</span> <span class="s2">&quot;Puppet version is: `puppet --version`&quot;</span></div><div class='line' id='LC21'><br/></div><div class='line' id='LC22'><span class="k">for </span>x in <span class="nv">$all_files</span>; <span class="k">do</span></div><div class='line' id='LC23'><span class="k">  case</span> <span class="nv">$x</span> in</div><div class='line' id='LC24'>&nbsp;&nbsp;*.pp <span class="o">)</span></div><div class='line' id='LC25'>&nbsp;&nbsp;&nbsp;&nbsp;puppet-lint <span class="se">\</span></div><div class='line' id='LC26'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-80chars-check <span class="se">\</span></div><div class='line' id='LC27'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-autoloader_layout-check <span class="se">\</span></div><div class='line' id='LC28'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-nested_classes_or_defines-check <span class="se">\</span></div><div class='line' id='LC29'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-only_variable_string-check <span class="se">\</span></div><div class='line' id='LC30'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-2sp_soft_tabs-check <span class="se">\</span></div><div class='line' id='LC31'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-trailing_whitespace-check <span class="se">\</span></div><div class='line' id='LC32'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--no-hard_tabs-check <span class="se">\</span></div><div class='line' id='LC33'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;--with-filename <span class="nv">$x</span></div><div class='line' id='LC34'><br/></div><div class='line' id='LC35'>&nbsp;&nbsp;&nbsp;&nbsp;puppet parser validate --render-as s --color<span class="o">=</span><span class="nb">false</span> <span class="nv">$x</span></div><div class='line' id='LC36'>&nbsp;&nbsp;&nbsp;&nbsp;;;</div><div class='line' id='LC37'>&nbsp;&nbsp;*.erb | *.rb <span class="o">)</span></div><div class='line' id='LC38'>&nbsp;&nbsp;&nbsp;&nbsp;erb -P -x -T <span class="s1">&#39;-&#39;</span> <span class="nv">$x</span> | ruby -c &gt; /dev/null</div><div class='line' id='LC39'>&nbsp;&nbsp;&nbsp;&nbsp;;;</div><div class='line' id='LC40'>&nbsp;&nbsp;*.sh <span class="o">)</span></div><div class='line' id='LC41'>&nbsp;&nbsp;&nbsp;&nbsp;bash -n <span class="nv">$x</span></div><div class='line' id='LC42'>&nbsp;&nbsp;&nbsp;&nbsp;;;</div><div class='line' id='LC43'>&nbsp;&nbsp;<span class="k">esac</span></div><div class='line' id='LC44'><span class="k">done</span></div><div class='line' id='LC45'><br/></div><div class='line' id='LC46'><span class="k">if</span> <span class="o">[</span> <span class="s2">&quot;$1&quot;</span> <span class="o">=</span> <span class="s2">&quot;-u&quot;</span> <span class="o">]</span>;</div><div class='line' id='LC47'><span class="k">then</span></div><div class='line' id='LC48'><span class="k">  </span><span class="nv">all_files</span><span class="o">=</span><span class="sb">`</span>find -iname <span class="s2">&quot;rakefile&quot;</span><span class="sb">`</span></div><div class='line' id='LC49'>&nbsp;&nbsp;<span class="nv">num_files</span><span class="o">=</span><span class="sb">`</span><span class="nb">echo</span> <span class="nv">$all_files</span> | wc -w<span class="sb">`</span></div><div class='line' id='LC50'>&nbsp;&nbsp;<span class="k">if </span><span class="nb">test</span> <span class="nv">$num_files</span> -eq <span class="s2">&quot;0&quot;</span> ; <span class="k">then</span></div><div class='line' id='LC51'><span class="k">    </span><span class="nb">echo</span> <span class="s2">&quot;WARNING: no Rakefile files found&quot;</span></div><div class='line' id='LC52'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">exit </span>0</div><div class='line' id='LC53'>&nbsp;&nbsp;<span class="k">fi</span></div><div class='line' id='LC54'><span class="k">  </span><span class="nb">echo</span> <span class="s2">&quot;Will run $num_files RSpec tests.&quot;</span></div><div class='line' id='LC55'>&nbsp;&nbsp;<span class="nb">echo</span> <span class="s2">&quot;Rake version is: `rake --version`&quot;</span></div><div class='line' id='LC56'><br/></div><div class='line' id='LC57'>&nbsp;&nbsp;<span class="k">for </span>file in <span class="nv">$all_files</span>; <span class="k">do</span></div><div class='line' id='LC58'><span class="k">    </span><span class="nv">d</span><span class="o">=</span><span class="sb">`</span>dirname <span class="nv">$file</span><span class="sb">`</span></div><div class='line' id='LC59'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">dn</span><span class="o">=</span><span class="sb">`</span>basename <span class="nv">$d</span><span class="sb">`</span></div><div class='line' id='LC60'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">cd</span> <span class="nv">$d</span></div><div class='line' id='LC61'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">rc</span><span class="o">=</span>0</div><div class='line' id='LC62'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">echo</span> <span class="s2">&quot;RSpec-ing $dn&quot;</span></div><div class='line' id='LC63'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">set</span> +e</div><div class='line' id='LC64'>&nbsp;&nbsp;&nbsp;&nbsp;rake spec</div><div class='line' id='LC65'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nv">rc</span><span class="o">=</span><span class="nv">$?</span></div><div class='line' id='LC66'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">set</span> -e</div><div class='line' id='LC67'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">if </span><span class="nb">test</span> <span class="nv">$rc</span> -ne 0 ; <span class="k">then</span></div><div class='line' id='LC68'><span class="k">      </span><span class="nv">fail</span><span class="o">=</span>1</div><div class='line' id='LC69'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="nb">echo</span> <span class="s2">&quot;ERROR in $dn (see above)&quot;</span></div><div class='line' id='LC70'>&nbsp;&nbsp;&nbsp;&nbsp;<span class="k">fi</span></div><div class='line' id='LC71'><span class="k">    </span><span class="nb">cd</span> <span class="k">${</span><span class="nv">WORKSPACE</span><span class="k">}</span></div><div class='line' id='LC72'>&nbsp;&nbsp;<span class="k">done</span></div><div class='line' id='LC73'><br/></div><div class='line' id='LC74'><span class="k">  if </span><span class="nb">test</span> <span class="nv">$fail</span> -ne 0 ; <span class="k">then</span></div><div class='line' id='LC75'><span class="k">    </span><span class="nb">echo</span> <span class="s2">&quot;RSpec Test FAILED: at least one module failed RSpec tests.&quot;</span></div><div class='line' id='LC76'>&nbsp;&nbsp;<span class="k">else</span></div><div class='line' id='LC77'><span class="k">    </span><span class="nb">echo</span> <span class="s2">&quot;RSpec Test SUCCEEDED: All modules successfully passed RSpec tests.&quot;</span></div><div class='line' id='LC78'>&nbsp;&nbsp;<span class="k">fi</span></div><div class='line' id='LC79'><span class="k">fi</span></div></pre></div>
            </td>
          </tr>
        </table>
  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" class="js-jump-to-line" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="http://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/">
      <span class="mega-octicon octicon-mark-github"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2013 <span title="0.02969s from github-fe113-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-fullscreen-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="js-fullscreen-contents" placeholder="" data-suggester="fullscreen_suggester"></textarea>
          <div class="suggester-container">
              <div class="suggester fullscreen-suggester js-navigation-container" id="fullscreen_suggester"
                 data-url="/Mirantis/fuel/suggestions/commit">
              </div>
          </div>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped leftwards" title="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped leftwards"
      title="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-remove-close close ajax-error-dismiss"></a>
      Something went wrong with that request. Please try again.
    </div>

    
  </body>
</html>

