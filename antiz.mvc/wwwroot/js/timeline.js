const timeline = {

    intervalToUpdateViews: 1000, // millisecond interval to send batch of statements displayed to the login 

    intervalToTriggerLoadMoreOnBottom : 777, 

    init: function () {
        this.statementIdQueue = []; // Array to collect statement IDs
        this.timerStarted = false; // To ensure only one timer runs


        this.bindEvents();
    },

    bindEvents: function () {

        const self = this;

        const targetElements = document.querySelectorAll('.statement-in-list');

        self.observer = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const statementId = $(entry.target).data("statementid");

                    if (!self.statementIdQueue.includes(statementId)) {
                        self.statementIdQueue.push(statementId);
                    }

                    observer.unobserve(entry.target);
                }
            });
        });

        // Observe all initial elements
        targetElements.forEach(el => self.observer.observe(el));
        

        self.startTimerForSendingBatchOfStatementsThatHasBeenDisplayed();

        self.loadMore();
        
        $(window).on('scroll', self.scrollHandler );
     
    },

    lastWindowTop: 0,
    scrollHandler: function () {
        const $main = $("main");
        const scrollTop = $(window).scrollTop(); 

        if (timeline.lastWindowTop >= scrollTop)
            return;

        const mainBottom = $main.offset().top + $main.outerHeight(); 
        const windowBottom = scrollTop + $(window).height(); 

        
        if (windowBottom >= mainBottom - 10) {
            $('#timeline-loading').removeClass("d-none");

            setTimeout(timeline.loadMore, timeline.intervalToTriggerLoadMoreOnBottom);
        }

        timeline.lastWindowTop = scrollTop;

    }, 

    startTimerForSendingBatchOfStatementsThatHasBeenDisplayed: function () {
        timeline.timerStarted = true;

        setInterval(() => {
            if (timeline.statementIdQueue.length > 0) {
                timeline.sendBatchRequest();
            }
        }, timeline.intervalToUpdateViews); 
    },

    sendBatchRequest: function () {
        if (timeline.statementIdQueue.length == 0) return;

        const url = `${location.origin}${bitMin.viewData.addViewUrl}`;

        $.ajax({
            url: url ,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify(timeline.statementIdQueue ), 
            success: (response) => {
                console.log('Batch sent successfully:', response);
            },
            error: (xhr, status, error) => {
                console.error('Error sending batch request:', error);
            }
        });

        timeline.statementIdQueue = []; 

    },

    addNewElements: function ($itemsFromvirtualDOM) {
        $itemsFromvirtualDOM.each((_, element) => {
            timeline.observer.observe(element);
        });
    },

    loadMore: function () {

        if ( timeline.isLoading )
            return;

        timeline.isLoading = true;

        const itemCount = $('.statement-in-list').length;
        console.log('Current item count:', itemCount);

        const separator = location.href.indexOf('?') > 0 ? '&' : '?';
        const url = `${location.href}${separator}LoadMoreFrom=${itemCount}`;

        $.ajax({
            url: url,
            type: 'GET',
            success: (data) => {
                const $newItems = $("<div>").html(data).find(".statement-in-list");

                if ($newItems.length > 0) {
                    $('#timelineContainer').append($newItems);
                    timeline.addNewElements($newItems);
                }

                $('#timeline-loading').addClass("d-none");
                timeline.isLoading = false;

            },
            error: (xhr, status, error) => {
                console.error('Error loading content:', error);
            }
        });
    }, 

    editStatement: function (statementId) {
        openToModal(bitMin.viewData.editStatementUrl +'/'+ statementId);
    },

    postStatementUpdate: function (btn) {
        const $form = $(this).closest('form');
        console.log( btn );
    }, 


    // scroll to current post

    lastTargetTop: 0,

    myScrollTo: function (id, callBackCount) {
        const self = this;

        if (self.lastTargetTop < -10000)
            return;

        if (callBackCount == undefined) {
            $(document).on('keydown', function (e) {
                switch (e.key) {
                    case "ArrowUp":
                    case "ArrowDown":
                    case "PageUp":
                    case "PageDown":
                    case "Home":
                    case "End":
                        self.lastTargetTop = -100000;
                }
            });
            $(window).on('wheel', function () {
                self.lastTargetTop = -100000;
            });
            $(window).on('touchmove', function () {
                self.lastTargetTop = -100000;
            });
        }

        if ($(window).scrollTop() != self.lastTargetTop)
            callBackCount = 0;
        else
            if (callBackCount > 10)
                return;

        self.lastTop = $(window).scrollTop();

        // console.log(`top ${self.lastTop} callback ${callBackCount}`);

        document.getElementById(id).scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });

        setTimeout(() => timeline.myScrollTo(id, (callBackCount || 0) + 1), 200);

    },

};
