package com.example.mustache_teste.mustache;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.security.web.authentication.SavedRequestAwareAuthenticationSuccessHandler;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;


import java.util.Map;

@Controller
@RequestMapping("/login")
public class LoginController {

        @GetMapping
        public String form() {
            return "login";
        }

    //    Neste exemplo simples, existe apenas um "caminho feliz" - todos os usuários são autenticados.
    //    Obviamente, este não é um processo de autenticação muito seguro e você deseja lançar um AuthenticationException,
    //    por exemplo BadCredentialsException, em um controlador real. A exceção seria tratada pelo Spring Security.
    //
    //    @PostMapping
    //    public void authenticate(@RequestParam Map<String, String> map) throws Exception {
    //        Authentication result = new UsernamePasswordAuthenticationToken(
    //                map.get("username"), "N/A",
    //                AuthorityUtils.commaSeparatedStringToAuthorityList("ROLE_USER"));
    //        SecurityContextHolder.getContext().setAuthentication(result);
    //    }


    // Para imitar o comportamento do formulário de login integrado do Spring Security,
    // você também precisa ser capaz de redirecionar para uma "solicitação salva" que o usuário tentou acessar antes do
    // login. O Spring Security tem uma AuthenticationSuccessHandlerabstração para isso e uma implementação simples que
    // conhece a solicitação salva. Portanto, o authenticatemétodo pode usar isso (ele precisa da solicitação e
    // resposta do servlet, que você pode adicionar como parâmetros de método e o Spring MVC os injetará)

    private AuthenticationSuccessHandler handler = new SavedRequestAwareAuthenticationSuccessHandler();

    @PostMapping
    public void authenticate(@RequestParam Map<String, String> map,
                             HttpServletRequest request, HttpServletResponse response) throws Exception {
        Authentication result = new UsernamePasswordAuthenticationToken(
                map.get("username"), "N/A",
                AuthorityUtils.commaSeparatedStringToAuthorityList("ROLE_USER"));
        handler.onAuthenticationSuccess(request, response, result);
    }
}
