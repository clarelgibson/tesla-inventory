<div id="top"></div>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/clarelgibson/tesla-inventory">
    <img src="./assets/img/tesla.png" alt="Tesla-style logo in website theme colours" height="80">
  </a>

<h3 align="center">Tesla Model 3 Inventory</h3>

  <p align="center">
    An interactive dashboard to show current UK inventory of Tesla Model 3 used vehicles, according to <a href="https://www.tesla.com/en_GB/inventory/used/m3">Tesla</a>.
    <br />
    <a href="https://github.com/clarelgibson/tesla-inventory"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://public.tableau.com/views/2022SchoolAdmissionsDashboard/2022SchoolAdmissionsDashboard?:language=en-US&:display_count=n&:origin=viz_share_link">View Dashboard</a> <!-- LINK TO BE UPDATED WHEN DASHBOARD PUBLISHED -->
    ·
    <a href="https://github.com/clarelgibson/tesla-inventory/issues">Report Bug</a>
    ·
    <a href="https://github.com/clarelgibson/tesla-inventory/issues">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#setup">Setup</a></li>
      </ul>
    </li>
    <li><a href="#attributes">Attributes</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

<!-- [![Product Name Screen Shot][product-screenshot]](https://example.com) -->

Exploratory analysis of Tesla inventory in the UK.

## Setup
The data for this project is scraped from the [Tesla UK Model 3 inventory of used cars](https://www.tesla.com/en_GB/inventory/used/m3). To scrape the inventory data into an R dataframe, I carried out the steps below. I used Safari for this exercise. I'm sure that the same actions can be taken in other browsers, however, I don't have experience with doing this in other browsers.

1. In Safari, navigate to the [Tesla inventory page for Model 3](https://www.tesla.com/en_GB/inventory/used/m3).
2. In the search pane on the left, enter a postcode and select "Used" under inventory type. Doing this will force the site to perform a search, which in turns opens up the API code in the backend for us to use.
3. Open the page source HTML by going to **Develop > Show Page Source (Opt + Cmd + U)**.
4. Here you need to locate the **Source** tab.
5. In the folder structure there should be a folder called **inventory > api > v1 > inventory-results**.
6. Right-click on the **inventory_results** filename and choose **Copy HTTP request** from the menu.
7. Paste the copied text into a text editor. The first part of the pasted text should look like this (there will be some other text below):

`:method: GET
:scheme: https
:authority: www.tesla.com
:path: /inventory/api/v1/inventory-results?query=%7B%22query%22%3A%7B%22model%22%3A%22m3%22%2C%22condition%22%3A%22used%22%2C%22options%22%3A%7B%7D%2C%22arrangeby%22%3A%22Price%22%2C%22order%22%3A%22asc%22%2C%22market%22%3A%22GB%22%2C%22language%22%3A%22en%22%2C%22super_region%22%3A%22north%20america%22%2C%22lng%22%3A-0.7876692%2C%22lat%22%3A51.2317088%2C%22zip%22%3A%22GU9%200NU%22%2C%22range%22%3A0%2C%22region%22%3A%22England%22%7D%2C%22offset%22%3A0%2C%22count%22%3A50%2C%22outsideOffset%22%3A0%2C%22outsideSearch%22%3Afalse%7D`

8. From this you can create a query string for an API call in R, by pasting together the **authority**, which is `www.tesla.com` and the **path**, which is `/inventory/api/v1/inventory-results?query=%7B%22query%22%...` (you should paste all the way to the end of the path string).
9. This string will now become your `url` variable in the `getData.R` script.

## Attributes
<div> Icons made by <a href="https://www.flaticon.com/authors/vitaly-gorbachev" title="Vitaly Gorbachev"> Vitaly Gorbachev </a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com'</a></div>