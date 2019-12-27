$(document).ready(function (){
    $('.tab-item').click(function(){
        $(".tab-item").each(function () {
            $(this).removeClass("tab-item-select");
        })
        $(this).addClass("tab-item-select");
        if($(this).html() == "单曲"){
            $(".sing").removeClass("hide");
            $(".sing-infom").addClass("hide");
        }else if($(this).html() == "简介"){
            $(".sing").addClass("hide");
            $(".sing-infom").removeClass("hide");
        }
    });
    

});