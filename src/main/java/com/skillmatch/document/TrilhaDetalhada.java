package com.skillmatch.document;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Document(collection = "trilhas_detalhadas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TrilhaDetalhada {

    @Id
    private String id;

    private Long idTrilhaRelacional;

    private String tituloTrilha;

    private String descricaoCompleta;

    private LocalDateTime dataCriacao;

    private String status; // Ativa, Inativa, etc.

    private List<Modulo> modulos;

    private List<Review> reviews;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Modulo {
        private String tituloModulo;
        private Integer duracaoHoras;
        private List<Aula> aulas;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Aula {
        private String titulo;
        private String urlVideo;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Review {
        private Long idTrabalhador;
        private Integer nota;
        private String comentario;
        private LocalDateTime dataReview;
    }
}