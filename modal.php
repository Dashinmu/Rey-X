<!-- Modal -->
<div class="modal fade" id="settingsModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">Изменить пароль</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="form-group">
                        <input type="password" class="form-control" id="oldPassword" placeholder="Введите старый пароль">
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" id="newPassword" placeholder="Введите новый пароль">
                    </div>
                    <div class="form-group">
                        <input type="password" class="form-control" id="confirmPassword" placeholder="Подтвердите новый пароль">
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primary btn-block">Подтвердить</button>
                <button type="button" class="btn btn-secondary btn-block" data-dismiss="modal">Закрыть</button>
            </div>
        </div>
    </div>
</div>

<script>
    function toggleMenu() {
        var menuContent = document.getElementById("menuContent");
        menuContent.classList.toggle("show-menu");
    }

    // Закрытие меню при клике вне его области
    window.addEventListener('click', function(event) {
        var menuContent = document.getElementById("menuContent");
        var menuToggler = document.querySelector(".user-info");
        var menuToggler1 = document.querySelector(".user-info img");
        var menuToggler2 = document.querySelector(".user-info span");
        if (
            !menuContent.contains(event.target) 
            && event.target !== menuToggler
            && event.target !== menuToggler1
            && event.target !== menuToggler2
        ) {
            menuContent.classList.remove("show-menu");
        }
    });

    $(function() {
        $(".stage-progress-circle").each(function() {
            var v_cnt = $(this).attr('data-correct-task');
            var v_all = $(this).attr('data-all-task');
            var value = getpercentageToTask(v_cnt, v_all);
            var left = $(this).find('.progress-circle-left .progress-circle');
            var right = $(this).find('.progress-circle-right .progress-circle');
            if (value > 0) {
                if (value <= 0.5) {
                    right.css('transform', 'rotate(' + percentageToDegrees(value) + 'deg)')
                } else {
                    right.css('transform', 'rotate(180deg)')
                    left.css('transform', 'rotate(' + percentageToDegrees(value - 0.5) + 'deg)')
                }
            }
        })
        function getpercentageToTask(v_cnt, v_all) {
            return v_cnt / v_all
        }
        function percentageToDegrees(percentage) {
            return percentage * 360
        }
    });
</script>