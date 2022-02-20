#!/usr/bin/python
# encoding: utf-8

from __future__ import print_function, unicode_literals, absolute_import

import functools
import re
import sys
from textwrap import wrap
from urllib import quote_plus

from algoliasearch.search_client import SearchClient
from config import Config
from workflow import Workflow3, ICON_INFO

# Algolia client
client = SearchClient.create(Config.ALGOLIA_APP_ID, Config.ALGOLIA_SEARCH_ONLY_API_KEY)
index = client.init_index(Config.ALGOLIA_SEARCH_INDEX)

# log
log = None


def cache_key(query, version=Config.DEFAULT_FLASK_VERSION):
    """Make filesystem-friendly cache key"""
    key = query + "_" + version
    key = key.lower()
    key = re.sub(r"[^a-z0-9-_;.]", "-", key)
    key = re.sub(r"-+", "-", key)
    # log.debug("Cache key : {!r} {!r} -> {!r}".format(query, version, key))
    return key


def handle_result(api_dict):
    """Extract relevant info from API result"""
    result = {}

    for key in {"id", "title", "permalink", "default", "content"}:
        result[key] = api_dict[key]

    return result


def search(
    query=None, version=Config.DEFAULT_FLASK_VERSION, limit=Config.RESULT_COUNT
):
    if query:
        results = index.search(
            query,
            {
                "facetFilters": ["version:{}".format(version)],
                "page": 0,
                "hitsPerPage": limit,
            },
        )
        if results is not None and "hits" in results:
            return results["hits"]
    return []


def main(wf):
    if wf.update_available:
        # Add a notification to top of Script Filter results
        wf.add_item(
            "New version available",
            "Action this item to install the update",
            autocomplete="workflow:update",
            icon=ICON_INFO,
        )

    query = wf.args[0].strip()

    # Tag prefix only. Treat as blank query
    if query == "v":
        query = ""

    if not query:
        wf.add_item("Search the Flask docs...")
        wf.send_feedback()
        return 0

    # Parse query into query string and tags
    words = query.split(" ")

    query = []
    version = Config.DEFAULT_FLASK_VERSION

    for word in words:
        if word.replace("v", "") in Config.SUPPORTED_FLASK_VERSIONS:
            version = word.replace("v", "")
        else:
            query.append(word)

    query = " ".join(query)

    # log.debug("version: {!r}".format(version))
    # log.debug("query: {!r}".format(query))

    key = cache_key(query, version)

    results = [
        handle_result(result)
        for result in wf.cached_data(
            key, functools.partial(search, query, version), max_age=Config.CACHE_MAX_AGE
        )
    ]

    # log.debug("{} results for {!r}".format(len(results), query))

    # Show results
    if not results:
        url = "https://www.google.com/search?q={}".format(
            quote_plus("Flask {}".format(query))
        )
        wf.add_item(
            "No matching answers found",
            "Shall I try and search Google?",
            valid=True,
            arg=url,
            copytext=url,
            quicklookurl=url,
            icon=Config.GOOGLE_ICON,
        )

    for result in results:
        subtitle = wrap(result["content"], width=75)[0]
        if len(result["content"]) > 75:
            subtitle += " ..."

        wf.add_item(
            uid=result["id"],
            title=result["id"],
            subtitle=subtitle,
            arg=result["permalink"],
            valid=True,
            largetext=result["title"],
            copytext=result["permalink"],
            quicklookurl=result["permalink"],
            icon=Config.FLASK_ICON,
        )
        # log.debug(result)

    wf.send_feedback()


if __name__ == "__main__":
    wf = Workflow3(
        update_settings={"github_slug": "techouse/alfred-flask-docs", "frequency": 7}
    )
    log = wf.logger
    sys.exit(wf.run(main))
