$(function() {
    function slide(index, slider) {
        slider.find('.slide.active').removeClass('active');
        slider.find(`.slide:nth-child(${index + 1})`).addClass('active');
        slider.find('.wrapper').css('transform', `translateX(${-1 * (1194 * (index))}px)`);
    }
    let startX, endX;
    $('.slider').on('touchstart', function(event) {
        startX = event.touches[0].clientX;
    });
    $('.slider').on('touchmove', function(event) {
        endX = event.touches[0].clientX;
    });
    $('.slider').on('touchend', function() {
        if(endX > 0) {
            const offset = startX - endX;
            const index = $('.slide.active', this).index();
            if(offset > 200 && index < 10) {
                slide(index + 1, $(this));
            }
            else if(offset < -200 && index > 0) {
                slide(index - 1, $(this));
            }
        }
        endX = 0;
    });
    $('.pdf').click(function() {
        location.href = `pdf://${$(this).data('pdf')}`;
    });
    $('.link').click(function() {
        const slider = $(this).parents('.slider');
        slider.addClass('sliding');
        slide($(this).data('link') - 1, slider);
        setTimeout(function() {
            slider.removeClass('sliding');
        }, 500);
    });
    $('.open-popup').click(function() {
        $(`.popup[data-popup="${$(this).data('popup')}"]`).addClass('active');
    });
    $('.close-popup').click(function() {
        $(`.popup[data-popup="${$(this).data('popup')}"]`).removeClass('active');
    });
});