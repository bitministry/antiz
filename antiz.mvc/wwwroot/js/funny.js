function addQueryToUrl(url, query) {
    return !query
        ? url
        : (url.includes("?")
            ? url + "&" + query
            : url + "?" + query);
}