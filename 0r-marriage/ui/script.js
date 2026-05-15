function FadeIn(Object, Timeout) {
    $(Object).fadeIn(Timeout).css('display', 'block');
} 

function FadeOut(Object, Timeout) {
    $(Object).fadeOut(Timeout)
    setTimeout(function(){
        $(Object).css("display", "none");
    }, Timeout)
}

var certificate = false

$(document).on("keydown", function(event) {
    if (event.repeat) {
        return;
    }
    switch (event.key) {
        case "Escape":
            if (!certificate) { return }
            $.post("https://0r-marriage/close")
            FadeOut('.marriage', 300);
            break;
        case "Backspace":
            if (!certificate) { return }
            $.post("https://0r-marriage/close")
            FadeOut('.marriage', 300);
            break;
    }
});

window.onload = function(e) {

    window.addEventListener("message", function(event) {
        var data = event.data;
        switch (data.action) {
            case 'openpriest':
                if (data.state) {
                    $('#priest_text').html('')
                    FadeIn('.priest', 250)
                } else {
                    $('#priest_text').html('')
                    FadeOut('.priest', 250)
                }
                break;
            case 'priest':
                $('#priest_text').html('')
                let priestlocale = data.letter;
                let index = 0;
                let speed = 30;
                let locale = ''
                
                function priest() {
                  if (index < priestlocale.length) {
                    locale += priestlocale.charAt(index);
                    $('#priest_text').html(locale)
                    index++;
                  } else {
                    clearInterval(intervalId);
                    $.post("https://0r-marriage/NextLetter");
                  }
                }
                
                intervalId = setInterval(priest, speed);
                break;
            case 'updatehud':
                var resimElementi = $("#heart");
                $('#menu_date').html(data.date.replace(/-/g, '.'))
                $('#menu_name').html(data.name)
                if (data.color == 'blue') {
                    $('.marri-menu').css('background', 'linear-gradient(to bottom,  rgba(0, 123, 255, 0.0), rgba(0, 123, 255, 0.2), rgba(0, 56, 168, 0.5),  rgba(0, 38, 122, 0.7))')
                    resimElementi.attr('src', 'img/blueheart.png');
                } else {
                    $('.marri-menu').css('background', 'linear-gradient(to bottom, rgba(229, 47, 99, 0.0), rgba(229, 47, 99, 0.2), rgba(208, 11, 50, 0.5), rgba(208, 11, 50, 0.6))')
                    resimElementi.attr('src', 'img/redheart.png');
                }
                break;
            case 'hudstate':
                if (data.state) {
                    FadeIn('.marri-menu', 250)
                } else {
                    FadeOut('.marri-menu', 250)
                }
                break;
            case 'lang':
                break;
            case 'propose':
                certificate = false
                $('#proposer_name').html('DO YOU AGGRE TO MARRY WITH MR. '+data.player)
                FadeIn('.container', 300)
                break;
            case 'certificate':
                $('.priest').html(data.data.priest)
                $('.time').html(data.data.clock)
                $('.loc').html(data.data.street)
                $('.groom').html(data.data.groom)
                $('.bride').html(data.data.bride)
                $('.name1').html(data.data.bride)
                $('.name2').html(data.data.groom)
                $('.date').html(data.data.date.replace(/-/g, '.'))
                $('.day').html(data.data.day)
                
                certificate = true
                FadeIn('.marriage', 300)
                break;
        }
    });
};

$(document).on('click', '.no', function(e) {
    e.preventDefault()
    FadeOut('.container', 200)
    $.post("https://0r-marriage/action", JSON.stringify({
        action: 'no'
    }));

});

$(document).on('click', '.yes', function(e) {
    e.preventDefault()
    FadeOut('.container', 200)
    $.post("https://0r-marriage/action", JSON.stringify({
        action: 'yes'
    }));
});