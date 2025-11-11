package com.skillmatch.service;

import com.skillmatch.document.TrilhaDetalhada;
// import com.skillmatch.entity.Habilidade; // Não é mais necessário aqui
import com.skillmatch.repository.TrilhaDetalhadaRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
// import java.util.Set; // Não é mais necessário aqui
// import java.util.stream.Collectors; // Não é mais necessário aqui

@Service
@Slf4j
public class TrilhaDetalhadaService {

    @Autowired
    private TrilhaDetalhadaRepository trilhaRepository;

    public TrilhaDetalhada criar(TrilhaDetalhada trilha) {
        log.info("Criando nova trilha detalhada: {}", trilha.getTituloTrilha());
        return trilhaRepository.save(trilha);
    }

    public Optional<TrilhaDetalhada> obterPorId(String id) {
        log.info("Buscando trilha detalhada com ID: {}", id);
        return trilhaRepository.findById(id);
    }

    public Optional<TrilhaDetalhada> obterPorIdRelacional(Long idTrilhaRelacional) {
        log.info("Buscando trilha detalhada por ID relacional: {}", idTrilhaRelacional);
        return trilhaRepository.findByIdTrilhaRelacional(idTrilhaRelacional);
    }

    public List<TrilhaDetalhada> listarTodas() {
        log.info("Listando todas as trilhas detalhadas");
        return trilhaRepository.findAll();
    }

    public List<TrilhaDetalhada> listarAtivas() {
        log.info("Listando trilhas detalhadas ativas");
        return trilhaRepository.findByStatus("Ativa");
    }

    public TrilhaDetalhada atualizar(String id, TrilhaDetalhada trilha) {
        log.info("Atualizando trilha detalhada com ID: {}", id);
        trilha.setId(id);
        return trilhaRepository.save(trilha);
    }

    public void deletar(String id) {
        log.info("Deletando trilha detalhada com ID: {}", id);
        trilhaRepository.deleteById(id);
    }

    /**
     * Recomenda uma trilha baseada nas habilidades exigidas
     *
     * !!! ESTE MÉTODO FOI COMENTADO PARA CORRIGIR O BUILD DA PIPELINE DEVOPS !!!
     * A lógica estava quebrada, pois a classe 'TrilhaDetalhada' não possui
     * o campo 'habilidades' ou 'habilidadesTrilha'.
     */
    /*
    public String recomendarTrilhaPorHabilidades(Set<Habilidade> habilidades) {
        log.info("Recomendando trilha para {} habilidades", habilidades.size());

        List<TrilhaDetalhada> trilhasAtivas = listarAtivas();

        // Encontra a trilha que cobre mais habilidades exigidas
        return trilhasAtivas.stream()
                // ESTA LINHA DAVA ERRO DE COMPILAÇÃO:
                .filter(trilha -> trilha.getHabilidadesTrilha() != null && !trilha.getHabilidadesTrilha().isEmpty()) 
                .map(trilha -> {
                    long cobertura = trilha.getHabilidadesTrilha().stream() // ESTA LINHA DAVA ERRO DE COMPILAÇÃO
                            .filter(hab -> habilidades.stream()
                                    .anyMatch(h -> h.getIdHabilidade().equals(hab.getIdHabilidade())))
                            .count();
                    return new Object() {
                        TrilhaDetalhada trilha_obj = trilha;
                        long cobertura_count = cobertura;
                    };
                })
                .max((a, b) -> Long.compare(a.cobertura_count, b.cobertura_count))
                .map(obj -> obj.trilha_obj.getTituloTrilha())
                .orElse("Nenhuma trilha disponível");
    }
    */

    public List<TrilhaDetalhada> buscarPorTitulo(String titulo) {
        log.info("Buscando trilhas por título: {}", titulo);
        return trilhaRepository.findByTituloTrilhaContainingIgnoreCase(titulo);
    }
}