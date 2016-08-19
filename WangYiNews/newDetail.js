window.onload = function(){
    
    var allImg = document.getElementsByTagName("img");
    
    for(var i=0; i<allImg.length;i++)
    {
        var img = allImg[i];
        img.id = i;
        img.onclick = function(){
            window.location.href = 'wy://imageClick:+' + this.id;
        }
        
    }
    

}


